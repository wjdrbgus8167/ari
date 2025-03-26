package com.ccc.ari.global.composition.controller;

import com.ccc.ari.community.domain.notice.client.NoticeCommentClient;
import com.ccc.ari.community.domain.notice.client.NoticeCommentDto;
import com.ccc.ari.global.composition.response.NoticeCommentListResponse;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class CommentCompositionController {

    private final NoticeCommentClient noticeCommentClient;

    @GetMapping("/api/v1/notices/{noticeId}/comments")
    public ApiUtils.ApiResponse<NoticeCommentListResponse> getNoticeCommentList(@PathVariable Integer noticeId) {
        // 1. noticeId에 해당하는 댓글 목록을 조회합니다.
        List<NoticeCommentDto> comments = noticeCommentClient.getCommentsByNoticeId(noticeId);

        // 2. 응답 데이터를 구성합니다.
        // TODO: 회원 Client 구현 시 응답 데이터에 추가하겠습니다.
        NoticeCommentListResponse response = NoticeCommentListResponse.from(comments);

        return ApiUtils.success(response);
    }
}
