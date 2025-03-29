package com.ccc.ari.community.infrastructure.comment.entity;

import com.ccc.ari.community.domain.comment.entity.AlbumComment;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 앨범 댓글 JPA 엔티티
 */
@Entity
@Table(name = "album_comments")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AlbumCommentJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "album_comment_id", nullable = false)
    private Integer albumCommentId;

    @Column(name = "album_id", nullable = false)
    private Integer albumId;

    @Column(name = "member_id", nullable = false)
    private Integer memberId;

    @Column(name = "content", nullable = false, length = 500)
    private String content;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "deleted_yn", nullable = false, columnDefinition = "boolean default false")
    private Boolean deletedYn;

    @Builder
    public AlbumCommentJpaEntity(Integer albumCommentId, Integer albumId, Integer memberId,
                                 String content, LocalDateTime createdAt, Boolean deletedYn) {
        this.albumCommentId = albumCommentId;
        this.albumId = albumId;
        this.memberId = memberId;
        this.content = content;
        this.createdAt = createdAt;
        this.deletedYn = deletedYn;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static AlbumCommentJpaEntity fromDomain(AlbumComment comment) {
        return AlbumCommentJpaEntity.builder()
                .albumCommentId(comment.getCommentId())
                .albumId(comment.getAlbumId())
                .memberId(comment.getMemberId())
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .deletedYn(comment.getDeletedYn())
                .build();
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public AlbumComment toDomain() {
        return new AlbumComment(albumCommentId, albumId, memberId, content, createdAt, deletedYn);
    }
}
