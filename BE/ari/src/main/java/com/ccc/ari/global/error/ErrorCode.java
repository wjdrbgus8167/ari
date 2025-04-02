package com.ccc.ari.global.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {


    // 인증 관련
    ACCESS_DENIED(HttpStatus.FORBIDDEN, "A001", "접근 권한이 없습니다."),
    EXPIRED_TOKEN(HttpStatus.UNAUTHORIZED, "A002", "토큰이 만료되었습니다."),
    INVALID_TOKEN(HttpStatus.UNAUTHORIZED, "A003", "토큰이 유효하지 않습니다."),
    AUTHENTICATION_FAILED(HttpStatus.UNAUTHORIZED, "A004", "인증에 실패하였습니다."),
    INVALID_PASSWORD(HttpStatus.UNAUTHORIZED, "A005", "비밀번호가 일치하지 않습니다."),
    MISSING_REFRESH_TOKEN(HttpStatus.BAD_REQUEST, "A006", "Refresh Token이 존재하지 않습니다."),
    INVALID_TOKEN_SIGNATURE(HttpStatus.UNAUTHORIZED, "A007", "잘못된 JWT 서명입니다."),
    UNSUPPORTED_TOKEN(HttpStatus.BAD_REQUEST, "A008", "지원되지 않는 JWT 토큰입니다."),
    INVALID_TOKEN_FORMAT(HttpStatus.BAD_REQUEST, "A009", "JWT 토큰 형식이 잘못되었습니다."),

    MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND,"M001", "해당 이메일로 등록된 사용자를 찾을 수 없습니다."),
    EMAIL_ALREADY_IN_USE(HttpStatus.CONFLICT, "M002", "이미 사용 중인 이메일입니다."),
    COMPANY_NOT_FOUND(HttpStatus.NOT_FOUND, "M003", "해당 이메일로 등록된 회사를 찾을 수 없습니다."),

    // 음원 재생 관련
    MUSIC_FILE_NOT_FOUND(HttpStatus.NOT_FOUND, "M001", "해당 음원을 찾을 수 없습니다."),
    MUSIC_STREAMING_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "M002", "음원 스트리밍 중 오류가 발생했습니다."),
    MUSIC_UNAUTHORIZED_ACCESS(HttpStatus.UNAUTHORIZED, "M003", "이 음원을 재생할 권한이 없습니다."),
    MUSIC_FORMAT_UNSUPPORTED(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "M004", "지원하지 않는 음원 형식입니다."),
    MUSIC_PLAYBACK_TIMEOUT(HttpStatus.REQUEST_TIMEOUT, "M005", "음원 재생 요청이 시간 초과되었습니다."),

    // S3 업로드 관련
    S3_UPLOAD_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "S001", "S3 파일 업로드 중 오류가 발생했습니다."),

    // 팬톡 관련
    FANTALK_CREATION_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "F001", "팬톡 생성 중 오류가 발생했습니다."),

    //플레이리스트 관련
    PLAYLIST_TRACK_ADD_FAIL(HttpStatus.NOT_FOUND,"P001","해당 트랙을 추가하는데 실패했습니다."),
    PLAYLIST_NOT_FOUND(HttpStatus.NOT_FOUND,"P002","해당 플레이리스트를 조회하는데 실패했습니다."),
    PLAYLIST_NOT_PUBLIC(HttpStatus.CONFLICT,"P003","해당 플레이리스트는 공개된 플레이리스트가 아닙니다."),
    PLAYLIST_TRACK_NOT_FOUND(HttpStatus.NOT_FOUND,"P004","트랙을 찾을 수 없습니다."),
    PLAYLIST_DUPLICATE_TRACK_SELECTED(HttpStatus.CONFLICT,"P005","선택한 곡들 중 중복된 곡이 존재합니다."),
    PLAYLIST_DUPLICATE_TRACK_EXISTED(HttpStatus.CONFLICT,"P006","플레이리스트에 이미 곡이 존재합니다."),

    //댓글 관련
    ALBUM_COMMENT_NOT_FOUND(HttpStatus.NOT_FOUND,"C001","앨범 댓글을 조회하는데 실패했습니다."),
    TRACK_COMMENT_NOT_FOUND(HttpStatus.NOT_FOUND,"C002","트랙 댓글을 찾을 수 없습니다."),

    INVALID_INPUT_PARAMETER(HttpStatus.BAD_REQUEST, "V001", "입력값이 유효하지 않습니다."),
    PASSWORD_REQUIRED(HttpStatus.BAD_REQUEST, "V002", "비밀번호는 필수입니다."),
    PASSWORD_TOO_SHORT(HttpStatus.BAD_REQUEST, "V003", "비밀번호는 최소 8자 이상이어야 합니다."),
    PASSWORD_TOO_LONG(HttpStatus.BAD_REQUEST, "V004", "비밀번호는 72자 이하여야 합니다."),
    EMAIL_REQUIRED(HttpStatus.BAD_REQUEST, "V005", "이메일은 필수입니다."),
    INVALID_EMAIL_FORMAT(HttpStatus.BAD_REQUEST, "V006", "유효하지 않은 이메일 형식입니다."),
    EMAIL_TOO_LONG(HttpStatus.BAD_REQUEST, "V007", "이메일은 30자 이하여야 합니다."),
    MEMBER_NICKNAME_REQUIRED(HttpStatus.BAD_REQUEST, "V008", "닉네임은 필수입니다."),
    MEMBER_NICKNAME_TOO_LONG(HttpStatus.BAD_REQUEST, "V009", "닉네임은 100자 이하여야 합니다."),

    GENRE_NOT_FOUND(HttpStatus.NOT_FOUND,"G001","존재하지 않는 장르입니다."),

    // 앨범 평점
    ALBUM_RATING_NOT_FOUND(HttpStatus.NOT_FOUND,"AR001","등록된 평점이 없습니다.");
    private final HttpStatus status;
    private final String code;
    private final String message;

}