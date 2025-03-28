package com.ccc.ari.community.ui.like.controller;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.application.like.service.AlbumLikeService;
import com.ccc.ari.community.ui.like.request.LikeRequest;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/albums/{albumId}")
@RequiredArgsConstructor
public class LikeController {

    private final AlbumLikeService albumLikeService;

    @PostMapping("/likes")
    public ApiUtils.ApiResponse<Void> updateAlbumLike(@PathVariable Integer albumId, @RequestBody LikeRequest request) {
        MemberUserDetails userDetails = (MemberUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Integer memberId = userDetails.getMemberId();

        LikeCommand command = request.toCommand(albumId, memberId);
        albumLikeService.updateAlbumLike(command);

        return ApiUtils.success(null);
    }
}
