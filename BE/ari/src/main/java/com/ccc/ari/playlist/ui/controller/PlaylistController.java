package com.ccc.ari.playlist.ui.controller;


import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.playlist.application.command.*;
import com.ccc.ari.playlist.application.service.PlaylistService;
import com.ccc.ari.playlist.application.service.integration.GetPublicPlaylistService;
import com.ccc.ari.playlist.ui.request.CreatePlaylistRequest;
import com.ccc.ari.playlist.ui.request.SetPlaylistPublicRequest;
import com.ccc.ari.playlist.ui.response.CreatePlaylistResponse;
import com.ccc.ari.playlist.ui.response.GetPublicPlaylistResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
@Slf4j
public class PlaylistController {

    private final PlaylistService playlistService;
    private final GetPublicPlaylistService getPublicPlaylistService;
    // 플레이리스트 생성
    @PostMapping
    public ApiUtils.ApiResponse<CreatePlaylistResponse> createPlaylist(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails,
            @RequestBody CreatePlaylistRequest request
    ){
        // 플레이리스트 제목과 함께 사용자의 memberId로 생성
        CreatePlaylistCommand command = request.requestToCommand(memberUserDetails.getMemberId());

        CreatePlaylistResponse response =playlistService.createPlaylist(command);

        // 플레이리스트 제목과 플레이리스트 id return
        return ApiUtils.success(response);
    }

    // 플레이리스트 공개로 전환히기
    @PutMapping("/{playlistId}/public")
    public ApiUtils.ApiResponse<?> publicPlaylist(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails,
            @RequestBody SetPlaylistPublicRequest request,
            @PathVariable Integer playlistId
    ) {
        // 기본적으로 플레이리스트를 생성하면 비공개(false)로 되어 있음.
        // 자신의 플레이리스트를 공개로 전환.
        // 추후 플레이리스트를 다시 비공개로 전환하는 api 생성 예정.
        PublicPlaylistCommand command = PublicPlaylistCommand.builder()
                .memberId(memberUserDetails.getMemberId())
                .publicYn(request.isPublicYn())
                .playlistId(playlistId)
                .build();

        playlistService.publicPlaylist(command);

        return ApiUtils.success("상태가 전환되었습니다.");
    }

    // 비공개 처리
    // 공개된 플레이 리스트 목록
    @GetMapping("/public")
    public ApiUtils.ApiResponse<GetPublicPlaylistResponse> getPlaylistDetail(
    ) {

        GetPublicPlaylistResponse response = getPublicPlaylistService.getPublicPlaylist();

        return ApiUtils.success(response);
    }
}
