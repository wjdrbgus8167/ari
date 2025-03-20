package com.ccc.ari.music.domain.service;

import com.ccc.ari.global.infrastructure.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UploadAlbumService {

    private final S3Service s3Service;

    // 앨범 커버 이미지 업로드
    public String uploadCoverImage(MultipartFile coverImage) {
        String coverFilePath = generateCoverFilePath(coverImage);
        return s3Service.uploadFileToS3(coverImage, coverFilePath);
    }

    // 일반 MP3 트랙 업로드
    public String uploadTrack(MultipartFile trackFile) {
        String trackFilePath = generateTrackFilePath(trackFile);
        return s3Service.uploadFileToS3(trackFile, trackFilePath);
    }

    /**
     * 앨범 커버 파일 경로 생성
     */
    private String generateCoverFilePath(MultipartFile file) {
        return "album/cover"+ UUID.randomUUID()  + getFileExtension(file.getOriginalFilename());
    }

    /**
     * 트랙 파일 경로 생성
     */
    private String generateTrackFilePath(MultipartFile file) {
        return "album/tracks/" + UUID.randomUUID() + getFileExtension(file.getOriginalFilename());
    }

    /**
     * 파일 확장자 추출
     */
    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return ""; // 확장자가 없을 경우 빈 문자열 반환
        }
        return filename.substring(filename.lastIndexOf(".")); // ".mp3" 또는 ".jpg" 형태로 반환
    }


}
