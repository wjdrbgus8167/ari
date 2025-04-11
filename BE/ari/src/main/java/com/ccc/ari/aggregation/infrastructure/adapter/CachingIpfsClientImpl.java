package com.ccc.ari.aggregation.infrastructure.adapter;

import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.domain.client.IpfsResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.ipfs.api.IPFS;
import io.ipfs.api.MerkleNode;
import io.ipfs.api.NamedStreamable;
import io.ipfs.multihash.Multihash;
import io.ipfs.cid.Cid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.CompletableFuture;
import java.util.function.Supplier;

@Component
public class CachingIpfsClientImpl implements IpfsClient {
    private static final Logger log = LoggerFactory.getLogger(CachingIpfsClientImpl.class);
    private static final int DEFAULT_MAX_RETRIES = 3;
    private static final long DEFAULT_RETRY_DELAY_MS = 1000;

    private final String ipfsApiUrl;
    private final String jwtToken;
    private final String gatewayDomain;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    // 동시성 처리를 위한 volatile 키워드 추가
    private volatile IPFS localNode;
    private final boolean useLocalCache;
    private volatile boolean actuallyUseCache;
    private final int timeout;
    private final Object lock = new Object();

    @Autowired
    public CachingIpfsClientImpl(
            @Value("${PINATA_ENDPOINT}") String ipfsApiUrl,
            @Value("${PINATA_JWT}") String jwtToken,
            @Value("${PINATA_GATEWAY}") String gatewayDomain,
            @Value("${IPFS_LOCAL_NODE_URL}") String localNodeUrl,
            @Value("${IPFS_USE_LOCAL_CACHE}") boolean useLocalCache,
            @Value("${IPFS_TIMEOUT:15000}") int timeout) {

        validateConfiguration(ipfsApiUrl, jwtToken, gatewayDomain, timeout);

        this.restTemplate = new RestTemplate();
        this.ipfsApiUrl = ipfsApiUrl;
        this.jwtToken = jwtToken;
        this.gatewayDomain = gatewayDomain;
        this.objectMapper = new ObjectMapper();
        this.timeout = timeout;
        this.useLocalCache = useLocalCache;
        this.actuallyUseCache = useLocalCache;

        if (useLocalCache) {
            initializeLocalNode(localNodeUrl);
        }
    }

    private void validateConfiguration(String ipfsApiUrl, String jwtToken,
                                       String gatewayDomain, int timeout) {
        if (StringUtils.isEmpty(ipfsApiUrl)) {
            throw new IllegalArgumentException("IPFS API URL must not be empty");
        }
        if (StringUtils.isEmpty(jwtToken)) {
            throw new IllegalArgumentException("JWT Token must not be empty");
        }
        if (StringUtils.isEmpty(gatewayDomain)) {
            throw new IllegalArgumentException("Gateway domain must not be empty");
        }
        if (timeout < 1000) {
            throw new IllegalArgumentException("Timeout must be at least 1000ms");
        }
    }

    private void initializeLocalNode(String localNodeUrl) {
        synchronized (lock) {
            try {
                this.localNode = new IPFS(localNodeUrl);
                this.localNode = this.localNode.timeout(timeout);
                log.info("IPFS 로컬 노드 캐싱 활성화: {}", localNodeUrl);
            } catch (Exception e) {
                log.error("IPFS 로컬 노드 초기화 실패", e);
                this.actuallyUseCache = false;
            }
        }
    }

    @Override
    public IpfsResponse save(String data) {
        log.info("IPFS에 데이터를 저장 중입니다...");
        return retryTemplate(() -> {
            try {
                return saveInternal(data);
            } catch (Exception e) {
                log.error("IPFS 저장 실패", e);
                throw new RuntimeException("IPFS 저장 실패", e);
            }
        });
    }

    private IpfsResponse saveInternal(String data) {
        MultiValueMap<String, Object> body = createMultipartBody(data);
        HttpHeaders headers = createHeaders();
        HttpEntity<MultiValueMap<String, Object>> requestEntity =
                new HttpEntity<>(body, headers);

        ResponseEntity<String> response = restTemplate.postForEntity(
                ipfsApiUrl, requestEntity, String.class);

        return processResponse(response);
    }

    private MultiValueMap<String, Object> createMultipartBody(String data) {
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        ByteArrayResource resource = new ByteArrayResource(
                data.getBytes(StandardCharsets.UTF_8)) {
            @Override
            public String getFilename() {
                return "data.json";
            }
        };
        body.add("file", resource);
        body.add("network", "public");
        return body;
    }

    private HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        headers.set("Authorization", "Bearer " + jwtToken);
        return headers;
    }

    private IpfsResponse processResponse(ResponseEntity<String> response) {
        if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
            throw new RuntimeException("IPFS 응답 실패: " + response.getStatusCode());
        }

        try {
            JsonNode root = objectMapper.readTree(response.getBody());
            String cid = root.path("data").path("cid").asText();

            if (StringUtils.isEmpty(cid)) {
                throw new RuntimeException("IPFS 응답에 CID가 없습니다");
            }

            return new IpfsResponse(cid);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("IPFS 응답 파싱 실패", e);
        }
    }

    private <T> T retryTemplate(Supplier<T> operation) {
        int retryCount = 0;
        while (true) {
            try {
                return operation.get();
            } catch (Exception e) {
                retryCount++;
                if (retryCount >= DEFAULT_MAX_RETRIES) {
                    throw e;
                }
                try {
                    Thread.sleep(DEFAULT_RETRY_DELAY_MS * retryCount);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    throw new RuntimeException(ie);
                }
                log.warn("작업 재시도 {}/{}", retryCount, DEFAULT_MAX_RETRIES);
            }
        }
    }

    @Override
    public String get(String ipfsPath) {
        log.info("IPFS에서 데이터 조회 시작: {}", ipfsPath);

        // 로컬 캐시 확인
        if (actuallyUseCache && localNode != null) {
            try {
                String localData = getFromLocalCache(ipfsPath);
                if (localData != null) {
                    return localData;
                }
            } catch (Exception e) {
                log.warn("로컬 캐시 조회 실패: {}", ipfsPath, e);
                // 로컬 캐시 실패 시 게이트웨이로 폴백
            }
        }

        // 게이트웨이에서 조회
        return retryTemplate(() -> getFromGateway(ipfsPath));
    }

    private String getFromLocalCache(String ipfsPath) {
        try {
            // 모든 CID가 bafk로 시작하므로 항상 block.get API 사용
            Multihash multihash = Cid.decode(ipfsPath);
            byte[] data = localNode.block.get(multihash);

            if (data != null && data.length > 0) {
                log.info("로컬 캐시에서 데이터 조회 성공: {}", ipfsPath);
                return new String(data, StandardCharsets.UTF_8);
            }
        } catch (Exception e) {
            log.warn("로컬 캐시 조회 중 오류 발생: {}", ipfsPath, e);
        }
        return null;
    }

    private String getFromGateway(String ipfsPath) {
        String gatewayUrl = buildGatewayUrl(ipfsPath);
        log.info("게이트웨이에서 데이터 조회 시작: {}", gatewayUrl);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + jwtToken);

            RequestEntity<?> request = RequestEntity
                    .get(new URI(gatewayUrl))
                    .headers(headers)
                    .build();

            ResponseEntity<String> response = restTemplate.exchange(
                    request,
                    String.class
            );

            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new RuntimeException("게이트웨이 응답 실패: " + response.getStatusCode());
            }

            // 성공적으로 데이터를 가져온 경우 로컬 캐시에 저장
            cacheResponseData(ipfsPath, response.getBody());

            return response.getBody();

        } catch (Exception e) {
            String errorMessage = String.format(
                    "IPFS 데이터 조회 실패 (path: %s): %s",
                    ipfsPath,
                    e.getMessage()
            );
            log.error(errorMessage, e);
            throw new RuntimeException(errorMessage, e);
        }
    }

    private String buildGatewayUrl(String ipfsPath) {
        return String.format(
                "https://%s/ipfs/%s",
                gatewayDomain,
                ipfsPath
        );
    }

    private void cacheResponseData(String ipfsPath, String data) {
        if (!actuallyUseCache || localNode == null) {
            return;
        }

        CompletableFuture.runAsync(() -> {
            try {
                byte[] bytes = data.getBytes(StandardCharsets.UTF_8);

                // 항상 block.put API 사용
                Optional<String> format = Optional.of("raw"); // 가장 기본적인 포맷

                NamedStreamable.ByteArrayWrapper file =
                        new NamedStreamable.ByteArrayWrapper(bytes);
                MerkleNode result = localNode.block.put(bytes, format);

                if (result == null) {
                    log.warn("블록 저장 결과가 비어있습니다: {}", ipfsPath);
                    return;
                }

                // 저장된 CID와 원본 CID 비교
                log.info("블록 저장 결과: {} -> {}", ipfsPath, result.hash.toString());

                try {
                    localNode.pin.add(result.hash);
                    log.info("데이터를 로컬 캐시에 저장 완료: {}", ipfsPath);
                } catch (Exception e) {
                    log.warn("핀 추가 중 오류 발생: {}", e.getMessage());
                }
            } catch (Exception e) {
                log.error("로컬 캐시 저장 실패: {}", ipfsPath, e);
            }
        });
    }

    // 커스텀 예외 클래스들
    public static class IpfsException extends RuntimeException {
        public IpfsException(String message) {
            super(message);
        }

        public IpfsException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    public static class IpfsTimeoutException extends IpfsException {
        public IpfsTimeoutException(String message) {
            super(message);
        }
    }

    public static class IpfsNotFoundException extends IpfsException {
        public IpfsNotFoundException(String message) {
            super(message);
        }
    }
}