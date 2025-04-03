package com.ccc.ari.global.composition.controller;

import com.ccc.ari.global.composition.service.GetPlaylistDetailService;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.GetPlaylistDetailCommand;
import com.ccc.ari.playlist.ui.response.GetPlaylistDetailResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class PlaylistDetailController {

    private final GetPlaylistDetailService getPlaylistDetailService;

    // 플레이리스트 상세 조회
    @GetMapping("/{playlistId}")
    public ApiUtils.ApiResponse<GetPlaylistDetailResponse> getPlaylistDetail(
            @PathVariable Integer playlistId
    ) {
        // 플레이리스트에 담긴 트랙(곡)들의 정보를 return
        GetPlaylistDetailCommand command = GetPlaylistDetailCommand.builder()
                .playlistId(playlistId).build();

        GetPlaylistDetailResponse response = getPlaylistDetailService.getPlaylistDetail(command);

        return ApiUtils.success(response);
    }
}
