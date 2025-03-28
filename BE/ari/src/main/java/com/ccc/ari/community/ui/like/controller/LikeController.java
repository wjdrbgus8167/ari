package com.ccc.ari.community.ui.like.controller;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.application.like.service.LikeService;
import com.ccc.ari.community.ui.like.request.LikeRequest;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/albums/{albumId}")
@RequiredArgsConstructor
public class LikeController {

    private final LikeService likeService;

    @PostMapping("/likes")
    public ApiUtils.ApiResponse<Void> updateAlbumLike(
            @PathVariable Integer albumId,
            @RequestBody LikeRequest request,
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        Integer memberId = userDetails.getMemberId();
        LikeCommand command = request.toCommand(albumId, memberId);
        likeService.updateAlbumLike(command);

        return ApiUtils.success(null);
    }

    @PostMapping("/tracks/{trackId}/likes")
    public ApiUtils.ApiResponse<Void> updateTrackLike(
            @PathVariable Integer albumId,
            @PathVariable Integer trackId,
            @RequestBody LikeRequest request,
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        Integer memberId = userDetails.getMemberId();
        LikeCommand command = request.toCommand(trackId, memberId);
        likeService.updateTrackLike(command);

        return ApiUtils.success(null);
    }
}
