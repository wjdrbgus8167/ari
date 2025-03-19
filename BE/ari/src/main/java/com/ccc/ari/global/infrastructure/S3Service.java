package com.ccc.ari.global.infrastructure;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;

@Service
@RequiredArgsConstructor
public class S3Service {

    private final S3Client s3Client;

    @Value("${spring.cloud.aws.s3.bucket}")
    private String bucketName;

    @Value("${spring.cloud.aws.region.static}")
    private String region;

    /**
     * S3에 파일 업로드 (파일 경로는 외부에서 결정)
     */
    public String uploadFileToS3(MultipartFile file, String filePath) throws IOException {
        s3Client.putObject(
                PutObjectRequest.builder()
                        .bucket(bucketName)
                        .key(filePath)
                        .contentType(file.getContentType())
                        .build(),
                RequestBody.fromInputStream(file.getInputStream(), file.getSize())
        );
        return getFileUrl(filePath);
    }

    /**
     * S3 파일 URL 생성
     */
    private String getFileUrl(String filePath) {
        return String.format("https://%s.s3.%s.amazonaws.com/%s", bucketName, region, filePath);
    }

}