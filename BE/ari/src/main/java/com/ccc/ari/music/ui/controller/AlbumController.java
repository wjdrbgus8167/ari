package com.ccc.ari.music.ui.controller;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.music.application.command.UploadAlbumCommand;
import com.ccc.ari.music.application.service.AlbumService;
import com.ccc.ari.music.application.service.integration.UploadAlbumService;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.mapper.AlbumMapper;
import com.ccc.ari.music.ui.request.UploadAlbumRequest;
import com.ccc.ari.music.ui.response.GenreTop5Response;
import com.ccc.ari.music.ui.response.UploadAlbumResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/albums")
@RequiredArgsConstructor
@Slf4j
public class AlbumController {

    private final UploadAlbumService uploadAlbumService;
    private final ObjectMapper objectMapper; // JSON 변환용
    private final AlbumService albumService;

    @PostMapping("/upload")
    public ApiUtils.ApiResponse<?> uploadAlbum(
            @RequestPart(value = "coverImage", required = true) MultipartFile coverImage,
            @RequestPart(value = "tracks", required = true) List<MultipartFile> tracks,
            @RequestPart(value = "metadata", required = true) String metadata,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {
        try {
            UploadAlbumRequest request = objectMapper.readValue(metadata, UploadAlbumRequest.class);
            UploadAlbumCommand command = request.toCommand(coverImage, tracks, memberUserDetails.getMemberId());
            UploadAlbumResponse response = uploadAlbumService.uploadAlbum(command);

            return ApiUtils.success(response);
        } catch (ApiException e) {
            // GenreService 등에서 발생한 도메인 예외는 그대로 전달
            log.error("업로드 도중 비즈니스 로직 예외 발생", e);
            return ApiUtils.error(e.getErrorCode());
        } catch (Exception e) {
            // 그 외 예상하지 못한 예외는 일반 오류로 처리
            log.error("음원 업로드 중 시스템 오류 발생", e);
            return ApiUtils.error(ErrorCode.MUSIC_FORMAT_UNSUPPORTED);
        }
    }

    // 장르별 인기 앨범 조회
    @GetMapping("/genre/{genreId}/most-like")
    public ApiUtils.ApiResponse<List<GenreTop5Response>> getTop5AlbumsByGenre(
            @PathVariable Integer genreId
    ) {
        // genreId는 1~5
        List<AlbumEntity> topAlbums = albumService.getTop5AlbumsByEachGenre(genreId);

        List<GenreTop5Response> response = topAlbums.stream()
                .map(GenreTop5Response::from)
                .toList();

        return ApiUtils.success(response);
    }

    // 최신 앨범 조회
    @GetMapping("/most-recent")
    public ApiUtils.ApiResponse<List<AlbumDto>> getRecentAlbumTop10() {

        List<AlbumEntity> albumDtoList = albumService.getTop10ByReleasedAt();

        return ApiUtils.success( albumDtoList.stream()
                .map(AlbumMapper::toDto)
                .collect(Collectors.toList()));
    }

    // 전체 인기앨범 조회
    @GetMapping("/most-like")
    public ApiUtils.ApiResponse<List<AlbumDto>> getMostLikedAlbumTop10() {

        List<AlbumEntity> albumDtoList = albumService.getTop10Album();

        return ApiUtils.success(albumDtoList.stream()
                .map(AlbumMapper::toDto)
                .collect(Collectors.toList()));
    }
}
