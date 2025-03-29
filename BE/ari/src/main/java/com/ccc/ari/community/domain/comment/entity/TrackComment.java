package com.ccc.ari.community.domain.comment.entity;

import lombok.Getter;

import java.time.LocalDateTime;

/**
 * 트랙 댓글 도메인 엔티티
 */
@Getter
public class TrackComment extends Comment {
    private final Integer trackId;
    private final String contentTimestamp;

    public TrackComment(Integer commentId, Integer trackId, Integer memberId, String content, String contentTimestamp, LocalDateTime createdAt, Boolean deletedYn) {
        super(commentId, memberId, content, createdAt, deletedYn);
        this.trackId = trackId;
        this.contentTimestamp = contentTimestamp;
    }

    public static TrackComment create(Integer trackId, Integer memberId, String content, String contentTimestamp) {
        return new TrackComment(null, trackId, memberId, content, contentTimestamp, LocalDateTime.now(), false);
    }
}
