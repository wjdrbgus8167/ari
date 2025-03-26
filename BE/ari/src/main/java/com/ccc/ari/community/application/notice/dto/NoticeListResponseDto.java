package com.ccc.ari.community.application.notice.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class NoticeListResponseDto {

    private List<NoticeResponseDto> notices;
    private int noticeCount;

    @Builder
    public NoticeListResponseDto(List<NoticeResponseDto> notices, int noticeCount) {
        this.notices = notices;
        this.noticeCount = noticeCount;
    }
}
