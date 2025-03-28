package com.ccc.ari.community.application.like.repository;

import com.ccc.ari.community.domain.like.entity.AlbumLike;

import java.util.Optional;

public interface AlbumLikeRepository {

    // 좋아요 저장
    void saveAlbumLike(AlbumLike albumLike);

    // 좋아요 조회
    Optional<AlbumLike> findByAlbumIdAndMemberId(Integer albumId, Integer memberId);
}
