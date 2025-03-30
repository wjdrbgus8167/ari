package com.ccc.ari.global.composition.infrastructure;

import com.ccc.ari.community.domain.comment.entity.TrackComment;

import java.util.List;

/*
    트랙 댓글 Client
     TODO : 추후에 수정 or 변경 예정. 아직 임시
 */
public interface TrackCommentClient {

    List<TrackComment> getTrackCommentsByTrackId(Integer trackId);
}
