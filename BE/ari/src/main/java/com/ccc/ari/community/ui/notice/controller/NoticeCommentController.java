package com.ccc.ari.community.ui.notice.controller;

import com.ccc.ari.community.application.notice.command.CreateCommentCommand;
import com.ccc.ari.community.application.notice.service.NoticeCommentService;
import com.ccc.ari.community.ui.notice.request.CreateCommentRequest;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/notices/{noticeId}/comments")
@RequiredArgsConstructor
public class NoticeCommentController {

    private final NoticeCommentService noticeCommentService;

    @PostMapping
    public ApiUtils.ApiResponse<Void> saveNoticeComment(@PathVariable Integer noticeId, @RequestBody CreateCommentRequest request) {
        // TODO: 인증 구현 완료 시 실제 로그인한 memberId로 수정하겠습니다.
        Integer memberId = 1;

        CreateCommentCommand command = CreateCommentCommand.builder()
                .noticeId(noticeId)
                .memberId(memberId)
                .content(request.getContent())
                .build();

        noticeCommentService.saveNoticeComment(command);

        return ApiUtils.success(null);
    }
}
