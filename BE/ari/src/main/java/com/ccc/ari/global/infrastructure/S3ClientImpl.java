package com.ccc.ari.global.infrastructure;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class S3ClientImpl implements S3Client {

    private final S3Service s3Service;

    /**
     * 팬톡 이미지 파일 경로 생성
     */
    @Override
    public String uploadImage(MultipartFile imageFile, String directory) {
        if (imageFile == null || imageFile.isEmpty()) {
            return null;
        }

        String imageFilePath = generateImagePath(imageFile, directory);
        return s3Service.uploadFileToS3(imageFile, imageFilePath);
    }

    /**
     * 팬톡 이미지 파일 경로 생성
     */
    private String generateImagePath(MultipartFile file, String directory) {
        return directory + "/images/" + UUID.randomUUID() + getFileExtension(file.getOriginalFilename());
    }

    /**
     * 파일 확장자 추출
     */
    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return ""; // 확장자가 없을 경우 빈 문자열 반환
        }
        return filename.substring(filename.lastIndexOf(".")); // ".jpg", ".png" 등 형태로 반환
    }
}
