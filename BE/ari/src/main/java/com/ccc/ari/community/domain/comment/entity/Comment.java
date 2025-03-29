package com.ccc.ari.community.domain.comment.entity;

import lombok.Getter;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Comment 도메인 엔티티
 * Album 및 Track 댓글의 공통 부분을 추상화합니다.
 */
@Getter
public abstract class Comment {

    private final Integer commentId;
    private final Integer memberId;
    private final String content;
    private final LocalDateTime createdAt;
    private final Boolean deletedYn;

    protected Comment(Integer commentId, Integer memberId, String content, LocalDateTime createdAt, Boolean deletedYn) {
        this.commentId = commentId;
        this.memberId = memberId;
        this.content = content;
        this.createdAt = createdAt;
        this.deletedYn = deletedYn;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Comment comment) {
            return comment.getCommentId().equals(commentId);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(commentId);
    }
}
