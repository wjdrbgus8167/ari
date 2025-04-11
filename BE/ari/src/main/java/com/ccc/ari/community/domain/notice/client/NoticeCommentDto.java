package com.ccc.ari.community.domain.notice.client;

import com.ccc.ari.community.domain.notice.entity.NoticeComment;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

/**
 * 공지사항 댓글 도메인의 데이터 전송 객체
 */
@Getter
@Builder
public class NoticeCommentDto {

    private Integer noticeCommentId;
    private Integer noticeId;
    private Integer memberId;
    private String content;
    private LocalDateTime createdAt;
    private Boolean deletedYn;

    /**
     * 도메인 엔티티를 DTO로 변환하는 메서드
     */
    public static NoticeCommentDto from(NoticeComment comment) {
        return NoticeCommentDto.builder()
                .noticeCommentId(comment.getNoticeCommentId())
                .noticeId(comment.getNoticeId())
                .memberId(comment.getMemberId())
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .build();
    }
}
