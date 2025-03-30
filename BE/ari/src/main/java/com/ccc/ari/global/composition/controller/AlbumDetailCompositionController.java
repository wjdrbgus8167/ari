package com.ccc.ari.global.composition.controller;

import com.ccc.ari.global.composition.response.AlbumDetailCompositionResponse;
import com.ccc.ari.global.composition.service.AlbumDetailCompositionService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController()
@RequiredArgsConstructor
public class AlbumDetailCompositionController {

    private final AlbumDetailCompositionService albumDetailCompositionService;

    // 앨범 상세 조회
    @GetMapping("/api/v1/albums/{albumId}")
    public ApiUtils.ApiResponse<AlbumDetailCompositionResponse> getAlbumDetail(@PathVariable Integer albumId) {

        AlbumDetailCompositionResponse response = albumDetailCompositionService.getAlbumDetail(albumId);

        return ApiUtils.success(response);
    }
}
