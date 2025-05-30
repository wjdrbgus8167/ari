package com.ccc.ari.community.domain.like.client;

import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.entity.Like;

import java.util.List;
import java.util.Optional;

public interface LikeClient {

    /**
     * 로그인한 회원의 좋아요 여부 확인
     *
     * @param targetId 앨범 ID 또는 트랙 ID
     * @param memberId 회원 ID
     * @param type 좋아요 대상 타입 (ALBUM 또는 TRACK)
     * @return 좋아요 여부
     */
    Boolean isLiked(Integer targetId, Integer memberId, LikeType type);
    Optional<Like> findByTargetAndMember(Integer targetId, Integer memberId, LikeType type);
    void saveLike(Like like, LikeType type);
    List<Like> findAllByMember(Integer memberId, LikeType type);
}
