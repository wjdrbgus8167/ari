package com.ccc.ari.community.infrastructure.follow.repository;

import com.ccc.ari.community.infrastructure.follow.entity.FollowJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FollowJpaRepository extends JpaRepository<FollowJpaEntity, Integer> {
    // 팔로우 관계 조회
    Optional<FollowJpaEntity> findByFollowerIdAndFollowingId(Integer followerId, Integer followingId);
}
