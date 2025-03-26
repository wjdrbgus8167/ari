package com.ccc.ari.community.application.notice.dto;

import com.ccc.ari.community.domain.notice.entity.Notice;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class NoticeResponseDto {

    private Integer noticeId;
    private String noticeContent;
    private String noticeImageUrl;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @Builder
    public NoticeResponseDto(Integer noticeId, String noticeContent, String noticeImageUrl, LocalDateTime createdAt) {
        this.noticeId = noticeId;
        this.noticeContent = noticeContent;
        this.noticeImageUrl = noticeImageUrl;
        this.createdAt = createdAt;
    }

    /**
     * 도메인 엔티티를 DTO로 변환하는 메서드
     */
    public static NoticeResponseDto from(Notice notice) {
        return NoticeResponseDto.builder()
                .noticeId(notice.getNoticeId())
                .noticeContent(notice.getContent().getContent())
                .noticeImageUrl(notice.getContent().getNoticeImageUrl())
                .createdAt(notice.getCreatedAt())
                .build();
    }
}
