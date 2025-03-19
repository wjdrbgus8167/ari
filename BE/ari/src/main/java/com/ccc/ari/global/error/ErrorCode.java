package com.ccc.ari.global.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    // 음원 재생 관련
    MUSIC_FILE_NOT_FOUND(HttpStatus.NOT_FOUND, "M001", "해당 음원을 찾을 수 없습니다."),
    MUSIC_STREAMING_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "M002", "음원 스트리밍 중 오류가 발생했습니다."),
    MUSIC_UNAUTHORIZED_ACCESS(HttpStatus.UNAUTHORIZED, "M003", "이 음원을 재생할 권한이 없습니다."),
    MUSIC_FORMAT_UNSUPPORTED(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "M004", "지원하지 않는 음원 형식입니다."),
    MUSIC_PLAYBACK_TIMEOUT(HttpStatus.REQUEST_TIMEOUT, "M005", "음원 재생 요청이 시간 초과되었습니다."),

    //S3 업로드 관련
    S3_UPLOAD_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "S001", "S3 파일 업로드 중 오류가 발생했습니다.");

    private final HttpStatus status;
    private final String code;
    private final String message;

}