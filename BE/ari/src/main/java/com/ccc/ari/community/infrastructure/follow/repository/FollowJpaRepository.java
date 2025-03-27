package com.ccc.ari.community.infrastructure.follow.repository;

import com.ccc.ari.community.infrastructure.follow.entity.FollowJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FollowJpaRepository extends JpaRepository<FollowJpaEntity, Integer> {
    // 팔로우 관계 조회
    Optional<FollowJpaEntity> findByFollowerIdAndFollowingId(Integer followerId, Integer followingId);

    // 팔로잉 목록 조회
    List<FollowJpaEntity> findAllByFollowerIdAndActivateYnTrue(Integer followerId);

    // 팔로워 목록 조회
    List<FollowJpaEntity> findAllByFollowingIdAndActivateYnTrue(Integer followingId);

    // 팔로잉 수 조회
    int countByFollowerIdAndActivateYnTrue(Integer followerId);

    // 팔로워 수 조회
    int countByFollowingIdAndActivateYnTrue(Integer followingId);

    // 여러 회원의 팔로워 수를 한 번에 조회하는 쿼리
    @Query("SELECT f.followingId, COUNT(f) FROM FollowJpaEntity f WHERE f.followingId IN :memberIds AND f.activateYn = true GROUP BY f.followingId")
    List<Object[]> countFollowersByMemberIdIn(List<Integer> memberIds);
}
