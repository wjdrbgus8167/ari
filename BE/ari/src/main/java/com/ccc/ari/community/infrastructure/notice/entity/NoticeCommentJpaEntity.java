package com.ccc.ari.community.infrastructure.notice.entity;

import com.ccc.ari.community.domain.notice.entity.NoticeComment;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Notice Comment JPA 엔티티
 */
@Entity
@Table(name = "notice_comments")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class NoticeCommentJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notice_comment_id", nullable = false)
    private Integer noticeCommentId;

    @Column(name = "notice_id", nullable = false)
    private Integer noticeId;

    @Column(name = "member_id", nullable = false)
    private Integer memberId;

    @Column(nullable = false, length = 500)
    private String content;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "deleted_yn", nullable = false, columnDefinition = "boolean default false")
    private Boolean deletedYn;

    @Builder
    public NoticeCommentJpaEntity(Integer noticeCommentId, Integer noticeId, Integer memberId, String content, LocalDateTime createdAt, Boolean deletedYn) {
        this.noticeCommentId = noticeCommentId;
        this.noticeId = noticeId;
        this.memberId = memberId;
        this.content = content;
        this.createdAt = createdAt;
        this.deletedYn = deletedYn;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static NoticeCommentJpaEntity fromDomain(NoticeComment comment) {
        return NoticeCommentJpaEntity.builder()
                .noticeCommentId(comment.getNoticeCommentId())
                .noticeId(comment.getNoticeId())
                .memberId(comment.getMemberId())
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .deletedYn(comment.getDeletedYn())
                .build();
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public NoticeComment toDomain() {
        return NoticeComment.builder()
                .noticeCommentId(noticeCommentId)
                .noticeId(noticeId)
                .memberId(memberId)
                .content(content)
                .createdAt(createdAt)
                .deletedYn(deletedYn)
                .build();
    }
}
