package com.ccc.ari.community.application.like.repository;

import com.ccc.ari.community.domain.like.entity.Like;

import java.util.Optional;

public interface LikeRepository {

    // 앨범 좋아요 저장
    void saveAlbumLike(Like like);

    // 트랙 좋아요 저장
    void saveTrackLike(Like like);

    // 앨범 좋아요 조회
    Optional<Like> findByAlbumIdAndMemberId(Integer albumId, Integer memberId);

    // 트랙 좋아요 조회
    Optional<Like> findByTrackIdAndMemberId(Integer trackId, Integer memberId);
}
