package com.ccc.ari.community.ui.like.controller;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.application.like.command.LikeStatusCommand;
import com.ccc.ari.community.application.like.service.LikeService;
import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.ui.like.request.LikeRequest;
import com.ccc.ari.community.ui.like.response.LikeStatusResponse;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/albums")
@RequiredArgsConstructor
public class LikeController {

    private final LikeService likeService;

    @GetMapping("/tracks/{trackId}/likes/status")
    public ApiUtils.ApiResponse<LikeStatusResponse> getTrackLikeStatus(
            @PathVariable Integer trackId,
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        Integer memberId = userDetails.getMemberId();
        LikeStatusCommand command = LikeStatusCommand.builder()
                .targetId(trackId)
                .memberId(memberId)
                .build();

        Boolean isLiked = likeService.hasLiked(command, LikeType.TRACK);

        LikeStatusResponse response = LikeStatusResponse.builder()
                .liked(isLiked)
                .build();

        return ApiUtils.success(response);
    }
}
