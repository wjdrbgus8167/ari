package com.ccc.ari.community.ui.comment.controller;

import com.ccc.ari.community.application.comment.command.CreateAlbumCommentCommand;
import com.ccc.ari.community.application.comment.command.CreateTrackCommentCommand;
import com.ccc.ari.community.application.comment.service.CommentService;
import com.ccc.ari.community.ui.comment.request.CreateAlbumCommentRequest;
import com.ccc.ari.community.ui.comment.request.CreateTrackCommentRequest;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/albums/{albumId}")
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;

    @PostMapping("/comments")
    public ApiUtils.ApiResponse<Void> createAlbumComment(
            @PathVariable Integer albumId,
            @RequestBody CreateAlbumCommentRequest request,
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        Integer memberId = userDetails.getMemberId();

        CreateAlbumCommentCommand command = CreateAlbumCommentCommand.builder()
                .albumId(albumId)
                .memberId(memberId)
                .content(request.getContent())
                .build();

        commentService.createAlbumComment(command);

        return ApiUtils.success(null);
    }

    @PostMapping("/tracks/{trackId}/comments")
    public ApiUtils.ApiResponse<Void> createTrackComment(
            @PathVariable Integer albumId,
            @PathVariable Integer trackId,
            @RequestBody CreateTrackCommentRequest request,
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        Integer memberId = userDetails.getMemberId();

        CreateTrackCommentCommand command = CreateTrackCommentCommand.builder()
                .trackId(trackId)
                .memberId(memberId)
                .content(request.getContent())
                .contentTimestamp(request.getContentTimestamp())
                .build();

        commentService.createTrackComment(command);

        return ApiUtils.success(null);
    }
}
