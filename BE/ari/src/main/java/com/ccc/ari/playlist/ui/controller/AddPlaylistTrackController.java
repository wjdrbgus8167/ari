package com.ccc.ari.playlist.ui.controller;

import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.AddTrackCommand;
import com.ccc.ari.playlist.application.service.integration.AddPlaylistTrackService;
import com.ccc.ari.playlist.ui.request.AddTrackRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class AddPlaylistTrackController {

    private final AddPlaylistTrackService addPlaylistTrackService;

    // 플레이리스트 트랙 추가
    @PostMapping("/{playlistId}/tracks")
    public ApiUtils.ApiResponse<?> addTrack(
            @PathVariable Integer playlistId,
            @RequestBody AddTrackRequest request
    ) {
        //플레이리스트 추가. 여러 개의 플레이리스트를 한 번에 추가하는 경우가 있어 Request는 List 형식
        AddTrackCommand command = request.toCommand(playlistId);
        addPlaylistTrackService.addTrack(command);

        return ApiUtils.success("플레이리스트 트랙 추가");
    }
}
