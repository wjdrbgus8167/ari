package com.ccc.ari.playlist.ui.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.SharePlaylistCommand;
import com.ccc.ari.playlist.application.service.integration.GetSharedPlaylistService;
import com.ccc.ari.playlist.ui.request.SharePlaylistRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class SharedPlaylistController {

    private final GetSharedPlaylistService sharedPlaylistService;

    @PostMapping("/share")
    public ApiUtils.ApiResponse<?> sharePlaylist(
            @RequestBody SharePlaylistRequest request,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {
        // 공개된 플레이리스트에 한해서 사용자가 플레이리스트를 퍼올 수 있음.
        // SharedPlaylist 테이블에 저장됨.
        SharePlaylistCommand command = request.requestToCommand(memberUserDetails.getMemberId());

        sharedPlaylistService.sharePlaylist(command);

        return ApiUtils.success("음원을 공유했습니다.");
    }
}
