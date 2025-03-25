package com.ccc.ari.community.domain.fantalk.client;

import org.springframework.web.multipart.MultipartFile;

/**
 * S3 연동 인터페이스
 */
public interface S3Client {

    /**
     * 이미지 저장
     * @param imageFile 이미지 파일
     * @param directory 저장 디렉토리
     * @return 저장된 이미지의 URL
     */
    String uploadImage(MultipartFile imageFile, String directory);
}
