package com.ccc.ari.community.ui.notice.controller;

import com.ccc.ari.community.application.notice.command.CreateNoticeCommand;
import com.ccc.ari.community.application.notice.service.NoticeService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/artists/notices")
@RequiredArgsConstructor
public class NoticeController {

    private final NoticeService noticeService;

    /**
     * 공지사항 생성 API
     */
    @PostMapping
    public ApiUtils.ApiResponse<Void> createNotice(
            @RequestPart(value = "noticeContent") String content,
            @RequestPart(value = "noticeImage", required = false) MultipartFile noticeImage
    ) {
        // TODO: 인증 구현 완료 시 실제 로그인한 memberId로 수정하겠습니다.
        Integer artistId = 1;

        CreateNoticeCommand command = CreateNoticeCommand.builder()
                .artistId(artistId)
                .noticeContent(content)
                .noticeImage(noticeImage)
                .build();

        noticeService.saveNotice(command);

        return ApiUtils.success(null);
    }
}
