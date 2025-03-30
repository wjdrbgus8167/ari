package com.ccc.ari.global.composition.controller;

import com.ccc.ari.global.composition.response.AlbumDetailResponse;
import com.ccc.ari.global.composition.service.AlbumDetailService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController()
@RequiredArgsConstructor
public class AlbumDetailCompositionController {

    private final AlbumDetailService albumDetailService;

    // 앨범 상세 조회
    @GetMapping("/api/v1/albums/{albumId}")
    public ApiUtils.ApiResponse<AlbumDetailResponse> getAlbumDetail(@PathVariable Integer albumId) {

        AlbumDetailResponse response = albumDetailService.getAlbumDetail(albumId);

        return ApiUtils.success(response);
    }
}
