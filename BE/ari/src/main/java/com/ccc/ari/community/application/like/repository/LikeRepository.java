package com.ccc.ari.community.application.like.repository;

import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.entity.Like;

import java.util.Optional;

public interface LikeRepository {

    // 좋아요 저장
    void saveLike(Like like, LikeType type);

    //  좋아요 조회
    Optional<Like> findByTargetAndMember(Integer albumId, Integer memberId, LikeType type);
}
