package com.ccc.ari.community.domain.notice.entity;

import com.ccc.ari.community.domain.notice.vo.NoticeContent;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

/**
 * Notice 도메인 엔티티
 */
@Builder
@Getter
public class Notice {

    private Integer noticeId;
    private Integer artistId;
    private LocalDateTime createdAt;
    @Builder.Default
    private Boolean deletedYn = false;
    private NoticeContent content;
}
