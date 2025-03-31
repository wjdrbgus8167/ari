package com.ccc.ari.community.domain.comment.client;

import com.ccc.ari.community.domain.comment.entity.TrackComment;

import java.util.List;

/**
 * 트랙 댓글 도메인에 접근하기 위한 클라이언트 인터페이스
 */
public interface TrackCommentClient {

    List<TrackComment> getTrackCommentsByTrackId(Integer trackId);
}
