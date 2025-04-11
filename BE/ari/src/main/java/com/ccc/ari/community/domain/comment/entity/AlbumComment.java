package com.ccc.ari.community.domain.comment.entity;

import lombok.Getter;

import java.time.LocalDateTime;

/**
 * 앨범 댓글 도메인 엔티티
 */
@Getter
public class AlbumComment extends Comment {
    private final Integer albumId;

    public AlbumComment(Integer commentId, Integer albumId, Integer memberId, String content, LocalDateTime createdAt, Boolean deletedYn) {
        super(commentId, memberId, content, createdAt, deletedYn);
        this.albumId = albumId;
    }

    public static AlbumComment create(Integer albumId, Integer memberId, String content) {
        return new AlbumComment(null, albumId, memberId, content, LocalDateTime.now(), false);
    }
}
