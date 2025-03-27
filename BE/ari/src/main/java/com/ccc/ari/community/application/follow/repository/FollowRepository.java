package com.ccc.ari.community.application.follow.repository;

import com.ccc.ari.community.domain.follow.entity.Follow;

import java.util.Optional;

/**
 * Follow 리포지토리 인터페이스
 */
public interface FollowRepository {
    // 팔로우 관계 저장
    void saveFollow(Follow follow);

    // 팔로우 관계 조회
    Optional<Follow> findByIds(Integer followerId, Integer followingId);
}
