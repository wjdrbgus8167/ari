package com.ccc.ari.aggregation.infrastructure.adapter;

import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.domain.client.IpfsResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;

@Component
public class IpfsClientImpl implements IpfsClient {

    private final String ipfsApiUrl;
    private final String apiKey;
    private final String apiKeySecret;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public IpfsClientImpl(@Value("${IPFS_API_URL}") String ipfsApiUrl,
                          @Value("${INFURA_API_KEY}") String apiKey,
                          @Value("${INFURA_API_KEY_SECRET}") String apiKeySecret) {
        this.restTemplate = new RestTemplate();
        this.ipfsApiUrl = ipfsApiUrl;
        this.objectMapper = new ObjectMapper();
        this.apiKey = apiKey;
        this.apiKeySecret = apiKeySecret;
    }

    /**
     * 데이터를 IPFS에 저장하고 CID를 반환합니다.
     *
     * @param data 직렬화된 문자열 데이터
     * @return IpfsResponse 객체 (CID 값을 포함)
     */
    public IpfsResponse save(String data) {
        // 1. multipart/form-data 요청 본문 생성
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        ByteArrayResource resource = new ByteArrayResource(data.getBytes(StandardCharsets.UTF_8)) {
            @Override
            public String getFilename() {
                return "data.json";
            }
        };
        body.add("file", resource);

        // 2. multipart/form-data용 헤더 설정 및 Basic Auth 헤더 추가
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        headers.setBasicAuth(apiKey, apiKeySecret);
        HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

        // 3. IPFS API 엔드포인트로 POST 요청 전송
        ResponseEntity<String> response = restTemplate.postForEntity(ipfsApiUrl, requestEntity, String.class);
        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            try {
                // IPFS API 응답 JSON 파싱
                // 응답 예시: {"Name":"data.json","Hash":"QmDummyCidExample","Size":"123"}
                JsonNode root = objectMapper.readTree(response.getBody());
                String cid = root.path("Hash").asText();
                if (cid == null || cid.isEmpty()) {
                    throw new RuntimeException("IPFS 응답에 CID가 포함되어 있지 않습니다.");
                }
                return new IpfsResponse(cid);
            } catch (JsonProcessingException e) {
                throw new RuntimeException("IPFS 응답 JSON 파싱 실패", e);
            }
        } else {
            throw new RuntimeException("IPFS에 데이터 업로드 실패. 상태 코드: " + response.getStatusCode());
        }
    }
}
