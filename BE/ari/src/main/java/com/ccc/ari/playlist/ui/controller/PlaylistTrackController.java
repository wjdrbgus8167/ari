package com.ccc.ari.playlist.ui.controller;

import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.DeletePlaylistTrackCommand;
import com.ccc.ari.playlist.application.service.PlaylistTrackService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class PlaylistTrackController {

    private final PlaylistTrackService playlistTrackService;

    // 플레이리스트 트랙 삭제
    @DeleteMapping("/{playlistId}/tracks/{trackId}")
    public ApiUtils.ApiResponse<?> deleteTrack(
            @PathVariable Integer playlistId,
            @PathVariable Integer trackId
    ) {
        DeletePlaylistTrackCommand command = DeletePlaylistTrackCommand.toCommand(playlistId,trackId);

        playlistTrackService.deletePlaylistTrack(command);

        return ApiUtils.success("플레이리스트 트랙 삭제");
    }
}
