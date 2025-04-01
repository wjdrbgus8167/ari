package com.ccc.ari.music.ui.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.music.application.service.integration.TrackPlayService;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/albums")
@RequiredArgsConstructor
@Slf4j
public class TrackController {

    private final TrackPlayService trackPlayService;

    // 음원 재생
    @PostMapping("/{albumId}/tracks/{trackId}")
    public ApiUtils.ApiResponse<TrackPlayResponse> trackPlay(
            @PathVariable Integer albumId,
            @PathVariable Integer trackId,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails) {

        return ApiUtils.success(trackPlayService.trackPlay(TrackPlayCommand.builder()
                .albumId(albumId)
                .trackId(trackId)
                .memberId(memberUserDetails.getMemberId())
                .nickname(memberUserDetails.getNickname())
                .build()));
    }
}
