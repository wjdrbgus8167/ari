package com.ccc.ari.global.composition.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.global.composition.service.TrackPlayService;
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
public class TrackPlayCompositionController {

    private final TrackPlayService trackPlayService;

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
