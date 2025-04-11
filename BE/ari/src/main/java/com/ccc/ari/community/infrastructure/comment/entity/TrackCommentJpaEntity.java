package com.ccc.ari.community.infrastructure.comment.entity;

import com.ccc.ari.community.domain.comment.entity.TrackComment;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Track 댓글 JPA 엔티티
 */
@Entity
@Table(name = "track_comments")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TrackCommentJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "track_comment_id")
    private Integer trackCommentId;

    @Column(name = "track_id", nullable = false)
    private Integer trackId;

    @Column(name = "member_id", nullable = false)
    private Integer memberId;

    @Column(name = "content", nullable = false, length = 500)
    private String content;

    @Column(name = "content_timestamp", length = 5)
    private String contentTimestamp;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "deleted_yn", nullable = false, columnDefinition = "boolean default false")
    private Boolean deletedYn;

    @Builder
    public TrackCommentJpaEntity(Integer trackCommentId, Integer trackId, Integer memberId, String content, String contentTimestamp, LocalDateTime createdAt, Boolean deletedYn) {
        this.trackCommentId = trackCommentId;
        this.trackId = trackId;
        this.memberId = memberId;
        this.content = content;
        this.contentTimestamp = contentTimestamp;
        this.createdAt = createdAt;
        this.deletedYn = deletedYn;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static TrackCommentJpaEntity fromDomain(TrackComment comment) {
        return TrackCommentJpaEntity.builder()
                .trackCommentId(comment.getCommentId())
                .trackId(comment.getTrackId())
                .memberId(comment.getMemberId())
                .content(comment.getContent())
                .contentTimestamp(comment.getContentTimestamp())
                .createdAt(comment.getCreatedAt())
                .deletedYn(comment.getDeletedYn())
                .build();
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public TrackComment toDomain() {
        return new TrackComment(trackCommentId, trackId, memberId, content, contentTimestamp, createdAt, deletedYn);
    }
}
