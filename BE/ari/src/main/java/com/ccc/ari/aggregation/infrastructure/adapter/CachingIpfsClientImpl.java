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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.CompletableFuture;

@Component
public class CachingIpfsClientImpl implements IpfsClient {

    private final String ipfsApiUrl;
    private final String jwtToken;
    private final String gatewayDomain;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final Logger log = LoggerFactory.getLogger(CachingIpfsClientImpl.class);

    // IPFS 로컬 노드 관련 필드
    private  IPFS localNode;
    private final boolean useLocalCache;
    private final int timeout;
    private boolean actuallyUseCache;

    @Autowired
    public CachingIpfsClientImpl(
            @Value("${PINATA_ENDPOINT}") String ipfsApiUrl,
            @Value("${PINATA_JWT}") String jwtToken,
            @Value("${PINATA_GATEWAY}") String gatewayDomain,
            @Value("${IPFS_LOCAL_NODE_URL}") String localNodeUrl,
            @Value("${IPFS_USE_LOCAL_CACHE}") boolean useLocalCache,
            @Value("${IPFS_TIMEOUT:15000}") int timeout) {

        this.restTemplate = new RestTemplate();
        this.ipfsApiUrl = ipfsApiUrl;
        this.jwtToken = jwtToken;
        this.gatewayDomain = gatewayDomain;
        this.objectMapper = new ObjectMapper();
        this.timeout = timeout;

        // 로컬 노드 초기화
        this.useLocalCache = useLocalCache;
        this.actuallyUseCache = useLocalCache;

        if (useLocalCache) {
            this.localNode = new IPFS(localNodeUrl);
            this.localNode = this.localNode.timeout(timeout);
            log.info("IPFS 로컬 노드 캐싱 활성화: {}", localNodeUrl);
        } else {
            this.localNode = null;
            log.info("IPFS 로컬 노드 캐싱 비활성화");
        }
    }

    /**
     * 데이터를 IPFS에 저장하고 CID를 반환합니다.
     * 저장된 데이터는 로컬 노드에도 캐싱됩니다.
     */
    @Override
    public IpfsResponse save(String data) {
        log.info("IPFS에 데이터를 저장 중입니다...");

        // 1. multipart/form-data 요청 본문 생성
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        ByteArrayResource resource = new ByteArrayResource(data.getBytes(StandardCharsets.UTF_8)) {
            @Override
            public String getFilename() {
                return "data.json";
            }
        };
        body.add("file", resource);
        body.add("network", "public");  // public 네트워크 선택

        // 2. 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        headers.set("Authorization", "Bearer " + jwtToken);
        HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

        // 3. Pinata API 요청 전송
        ResponseEntity<String> response = restTemplate.postForEntity(ipfsApiUrl, requestEntity, String.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            try {
                // Pinata API 응답 JSON 파싱
                JsonNode root = objectMapper.readTree(response.getBody());

                // data.cid에서 CID 추출
                String cid = root.path("data").path("cid").asText();
                if (cid == null || cid.isEmpty()) {
                    log.error("IPFS 응답에 CID가 포함되어 있지 않습니다.");
                    throw new RuntimeException("IPFS 응답에 CID가 포함되어 있지 않습니다.");
                }

                // 추가 정보 로깅
                String fileName = root.path("data").path("name").asText();
                long fileSize = root.path("data").path("size").asLong();
                log.info("IPFS에 데이터 저장 성공. 파일명: {}, 크기: {} bytes, CID: {}", fileName, fileSize, cid);

                // 로컬 노드에 데이터 캐싱 (비동기)
                if (useLocalCache) {
                    cacheToLocalNode(cid, data);
                }

                return new IpfsResponse(cid);
            } catch (JsonProcessingException e) {
                log.error("IPFS 응답 JSON 파싱 실패", e);
                throw new RuntimeException("IPFS 응답 JSON 파싱 실패", e);
            }
        } else {
            log.error("IPFS에 데이터 업로드 실패. 상태 코드: {}", response.getStatusCode());
            throw new RuntimeException("IPFS에 데이터 업로드 실패. 상태 코드: " + response.getStatusCode());
        }
    }

    @Override
    public String get(String ipfsPath) {
        log.info("IPFS에서 데이터를 가져오는 중입니다. CID: {}", ipfsPath);

        // 로컬 노드 캐싱이 활성화된 경우
        if (actuallyUseCache && localNode != null) {
            try {
                // 로컬 노드에서 데이터 조회 시도
                String localData = getFromLocalNode(ipfsPath);
                if (localData != null) {
                    log.info("로컬 IPFS 노드에서 데이터 조회 성공. CID: {}", ipfsPath);
                    return localData;
                }
            } catch (Exception e) {
                log.debug("로컬 IPFS 노드에서 데이터 조회 실패, 게이트웨이로 전환합니다. CID: {}", ipfsPath);
            }
        }

        // 로컬 노드에서 데이터를 찾지 못하면 Pinata 게이트웨이에서 조회
        try {
            // Pinata 공개 게이트웨이 URL 구성
            String gatewayUrl = "https://" + gatewayDomain + "/ipfs/" + ipfsPath;

            // GET 요청 전송
            ResponseEntity<String> response = restTemplate.getForEntity(gatewayUrl, String.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                String data = response.getBody();
                log.info("Pinata 게이트웨이에서 데이터 조회 성공. 응답 크기: {} bytes", data.length());

                // 로컬 노드에 데이터 캐싱 (비동기)
                if (useLocalCache) {
                    cacheToLocalNode(ipfsPath, data);
                }

                return data;
            } else {
                log.error("IPFS 데이터 조회 실패. 상태 코드: {}", response.getStatusCode());
                throw new RuntimeException("IPFS 데이터 조회 실패. 상태 코드: " + response.getStatusCode());
            }
        } catch (Exception e) {
            log.error("IPFS 데이터 조회 중 오류 발생", e);
            throw new RuntimeException("IPFS 데이터 조회 중 오류 발생: " + e.getMessage(), e);
        }
    }

    /**
     * 로컬 IPFS 노드에서 데이터를 조회합니다.
     */
    private String getFromLocalNode(String cid) throws IOException {
        if (localNode == null) return null;

        try {
            // CIDv1 (bafk...) 형식 처리
            Multihash fileMultihash;
            if (cid.startsWith("bafk")) {
                fileMultihash = io.ipfs.cid.Cid.decode(cid);
            } else {
                fileMultihash = Multihash.fromBase58(cid);
            }

            byte[] data = localNode.cat(fileMultihash);
            if (data != null && data.length > 0) {
                return new String(data, StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
            log.debug("로컬 노드에서 데이터를 찾을 수 없음: {}", cid);
            throw e;
        }
        return null;
    }

    /**
     * 데이터를 로컬 IPFS 노드에 비동기적으로 캐싱합니다.
     */
    private void cacheToLocalNode(String cid, String data) {
        if (!actuallyUseCache || localNode == null) return;

        CompletableFuture.runAsync(() -> {
            int maxRetries = 2;
            int retryCount = 0;

            while (retryCount <= maxRetries) {
                try {
                    log.debug("캐싱 시도 CID: {} (시도 #{}/{})", cid, retryCount + 1, maxRetries + 1);

                    // CIDv1 (bafk...) 형식 처리
                    Multihash fileMultihash;
                    if (cid.startsWith("bafk")) {
                        fileMultihash = io.ipfs.cid.Cid.decode(cid);
                    } else {
                        fileMultihash = Multihash.fromBase58(cid);
                    }

                    // 이미 캐싱되어 있는지 확인 (짧은 타임아웃으로 빠르게 체크)
                    try {
                        // 더 짧은 타임아웃으로 체크
                        IPFS quickCheck = localNode.timeout(5000);
                        byte[] existingData = quickCheck.cat(fileMultihash);
                        if (existingData != null && existingData.length > 0) {
                            log.debug("데이터가 이미 로컬 노드에 캐싱되어 있음: {}", cid);
                            return;
                        }
                    } catch (IOException e) {
                        // 존재하지 않으면 계속 진행
                    }

                    // 데이터를 로컬 노드에 추가
                    byte[] bytes = data.getBytes(StandardCharsets.UTF_8);
                    NamedStreamable.ByteArrayWrapper file = new NamedStreamable.ByteArrayWrapper(bytes);
                    MerkleNode addResult = localNode.add(file).get(0);

                    // 추가된 파일 핀 (더 짧은 타임아웃)
                    IPFS pinIpfs = localNode.timeout(15000);
                    pinIpfs.pin.add(fileMultihash);

                    log.info("데이터가 로컬 노드에 성공적으로 캐싱됨: {}", cid);
                    return; // 성공하면 루프 종료
                } catch (Exception e) {
                    retryCount++;
                    if (retryCount <= maxRetries) {
                        log.warn("로컬 노드에 캐싱 중 오류 발생: {}, 재시도 {}/{}", cid, retryCount, maxRetries);
                        try {
                            // 잠시 대기 후 재시도
                            Thread.sleep(1000 * retryCount);
                        } catch (InterruptedException ie) {
                            Thread.currentThread().interrupt();
                        }
                    } else {
                        log.warn("로컬 노드에 캐싱 실패 (최대 재시도 횟수 초과): {}, 오류: {}", cid, e.getMessage());
                    }
                }
            }
        });
    }

    /**
     * CID가 로컬 노드에 존재하는지 확인합니다.
     */
    public boolean isAvailableLocally(String cid) {
        if (!useLocalCache || localNode == null) return false;

        try {
            Multihash fileMultihash = Multihash.fromBase58(cid);
            byte[] data = localNode.cat(fileMultihash);
            return data != null && data.length > 0;
        } catch (Exception e) {
            return false;
        }
    }
}