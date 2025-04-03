package com.ccc.ari.playlist.ui.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.GetPlaylistCommand;
import com.ccc.ari.playlist.application.service.integration.GetPlaylistService;
import com.ccc.ari.playlist.ui.response.GetPlayListResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class GetPlaylistController {

    private final GetPlaylistService getPlaylistService;

    @GetMapping
    public ApiUtils.ApiResponse<GetPlayListResponse> getPlaylist(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {
        log.info("플레이리스트 조회 :{}", memberUserDetails.getMemberId());
        // 사용자는 본인이 만든 플레이리스트와 퍼온 플레이리스트가 존재.
        // 자신의 플레이리스트 전체를 조회하여 플레이리스트 제목과 id, 플레이리스트에 담긴 곡 개수를 return
        GetPlaylistCommand command = GetPlaylistCommand.builder()
                .memberId(memberUserDetails.getMemberId())
                .build();
        GetPlayListResponse response = getPlaylistService.getPlaylist(command);
        log.info("플레이리스트 조회 :{}", response.getPlaylists());
        return ApiUtils.success(response);
    }
}
