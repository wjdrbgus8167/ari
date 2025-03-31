package com.ccc.ari.community.ui.notice.controller;

import com.ccc.ari.community.application.notice.command.CreateNoticeCommand;
import com.ccc.ari.community.application.notice.dto.NoticeListResponseDto;
import com.ccc.ari.community.application.notice.dto.NoticeResponseDto;
import com.ccc.ari.community.application.notice.service.NoticeService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/artists")
@RequiredArgsConstructor
public class NoticeController {

    private final NoticeService noticeService;

    /**
     * 공지사항 생성 API
     */
    @PostMapping("/notices")
    public ApiUtils.ApiResponse<Void> createNotice(
            @RequestPart(value = "noticeContent") String content,
            @RequestPart(value = "noticeImage", required = false) MultipartFile noticeImage
    ) {
        MemberUserDetails userDetails = (MemberUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Integer artistId = userDetails.getMemberId();

        CreateNoticeCommand command = CreateNoticeCommand.builder()
                .artistId(artistId)
                .noticeContent(content)
                .noticeImage(noticeImage)
                .build();

        noticeService.saveNotice(command);

        return ApiUtils.success(null);
    }

    /**
     * 공지사항 목록 조회 API
     */
    @GetMapping("/{memberId}/notices")
    public ApiUtils.ApiResponse<NoticeListResponseDto> getNoticeList(@PathVariable Integer memberId) {
        NoticeListResponseDto responseDto = noticeService.getNoticeList(memberId);
        return ApiUtils.success(responseDto);
    }

    /**
     * 공지사항 상세 조회 API
     */
    @GetMapping("/notices/{noticeId}")
    public ApiUtils.ApiResponse<NoticeResponseDto> getNotice(@PathVariable Integer noticeId) {
        NoticeResponseDto responseDto = noticeService.getNotice(noticeId);
        return ApiUtils.success(responseDto);
    }

    /**
     * 최근 공지사항 조회 API
     */
    @GetMapping("/{memberId}/notices/latest")
    public ApiUtils.ApiResponse<NoticeResponseDto> getLatestNotice(@PathVariable Integer memberId) {
        NoticeResponseDto response = noticeService.getLatestNotice(memberId);
        return ApiUtils.success(response);
    }
}
