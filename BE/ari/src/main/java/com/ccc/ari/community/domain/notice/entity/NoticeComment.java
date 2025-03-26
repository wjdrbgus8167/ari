package com.ccc.ari.community.domain.notice.entity;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

/**
 * 공지사항 댓글 도메인 엔티티
 */
@Getter
@Builder
public class NoticeComment {

    private Integer noticeCommentId;
    private Integer noticeId;
    private Integer memberId;
    private String content;
    private LocalDateTime createdAt;
    @Builder.Default
    private Boolean deletedYn = false;

    /**
     * 댓글 삭제 (soft delete)
     */
    public void delete() {
        if (this.deletedYn) {
            throw new IllegalStateException("이미 삭제된 댓글입니다.");
        }
        this.deletedYn = true;
    }
}
