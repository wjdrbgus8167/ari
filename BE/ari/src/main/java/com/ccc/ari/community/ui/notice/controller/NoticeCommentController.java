package com.ccc.ari.community.ui.notice.controller;

import com.ccc.ari.community.application.notice.command.CreateCommentCommand;
import com.ccc.ari.community.application.notice.service.NoticeCommentService;
import com.ccc.ari.community.ui.notice.request.CreateCommentRequest;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/notices/{noticeId}/comments")
@RequiredArgsConstructor
public class NoticeCommentController {

    private final NoticeCommentService noticeCommentService;

    @PostMapping
    public ApiUtils.ApiResponse<Void> saveNoticeComment(@PathVariable Integer noticeId, @RequestBody CreateCommentRequest request) {
        MemberUserDetails userDetails = (MemberUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Integer memberId = userDetails.getMemberId();

        CreateCommentCommand command = CreateCommentCommand.builder()
                .noticeId(noticeId)
                .memberId(memberId)
                .content(request.getContent())
                .build();

        noticeCommentService.saveNoticeComment(command);

        return ApiUtils.success(null);
    }
}
