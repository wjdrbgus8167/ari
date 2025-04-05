package com.ccc.ari.global.composition.controller.community;

import com.ccc.ari.global.composition.response.community.NoticeCommentListResponse;
import com.ccc.ari.global.composition.response.community.TrackCommentListResponse;
import com.ccc.ari.global.composition.service.community.CommentListService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class CommentCompositionController {

    private final CommentListService commentListService;

    @GetMapping("/api/v1/notices/{noticeId}/comments")
    public ApiUtils.ApiResponse<NoticeCommentListResponse> getNoticeCommentList(@PathVariable Integer noticeId) {

        NoticeCommentListResponse response = commentListService.getNoticeCommentList(noticeId);

        return ApiUtils.success(response);
    }

    @GetMapping("/api/v1/albums/tracks/{trackId}/comments")
    public ApiUtils.ApiResponse<TrackCommentListResponse> getTrackCommentsList(@PathVariable Integer trackId) {

        TrackCommentListResponse response = commentListService.getTrackCommentList(trackId);

        return ApiUtils.success(response);
    }
}
