package com.ccc.ari.global.composition.controller;

import com.ccc.ari.community.application.notice.service.NoticeCommentService;
import com.ccc.ari.community.domain.notice.client.NoticeCommentClient;
import com.ccc.ari.global.composition.response.NoticeCommentListResponse;
import com.ccc.ari.global.composition.service.CommentListService;
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
}
