package com.ccc.ari.playlist.ui.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.DeletePlaylistCommand;
import com.ccc.ari.playlist.application.service.integration.DeletePlaylistService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class DeletePlaylistController {

    private final DeletePlaylistService deletePlaylistService;

    @DeleteMapping("/{playlistId}")
    public ApiUtils.ApiResponse<?> deletePlaylist(
            @PathVariable Integer playlistId,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {

        DeletePlaylistCommand command = DeletePlaylistCommand.builder()
                .playlistId(playlistId)
                .memberId(memberUserDetails.getMemberId())
                .build();

        deletePlaylistService.deletePlaylist(command);

        return ApiUtils.success("플레이리스트가 삭제되었습니다.");
    }
}
