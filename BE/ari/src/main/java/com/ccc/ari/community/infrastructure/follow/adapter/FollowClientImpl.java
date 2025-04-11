package com.ccc.ari.community.infrastructure.follow.adapter;

import com.ccc.ari.community.domain.follow.client.FollowClient;
import com.ccc.ari.community.domain.follow.client.FollowerDto;
import com.ccc.ari.community.domain.follow.client.FollowingDto;
import com.ccc.ari.community.infrastructure.follow.entity.FollowJpaEntity;
import com.ccc.ari.community.infrastructure.follow.repository.FollowJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class FollowClientImpl implements FollowClient {

    private final FollowJpaRepository followJpaRepository;

    @Override
    public List<FollowingDto> getFollowingsByMemberId(Integer memberId) {
        // 1. JPA 리포지토리를 통해 팔로잉 엔티티 목록을 조회합니다.
        List<FollowJpaEntity> jpaEntities = followJpaRepository.findAllByFollowerIdAndActivateYnTrue(memberId);

        // 2. JPA 엔티티 -> 도메인 엔티티 -> DTO로 변환합니다.
        return jpaEntities.stream()
                .map(FollowJpaEntity::toDomain)
                .map(FollowingDto::from)
                .toList();
    }

    @Override
    public List<FollowerDto> getFollowersByMemberId(Integer memberId) {
        // 1. JPA 리포지토리를 통해 팔로워 엔티티 목록을 조회합니다.
        List<FollowJpaEntity> jpaEntities = followJpaRepository.findAllByFollowingIdAndActivateYnTrue(memberId);

        // 2. JPA 엔티티 -> 도메인 엔티티 -> DTO로 변환합니다.
        return jpaEntities.stream()
                .map(FollowJpaEntity::toDomain)
                .map(FollowerDto::from)
                .toList();
    }

    @Override
    public int countFollowingsByMemberId(Integer memberId) {
        return followJpaRepository.countByFollowerIdAndActivateYnTrue(memberId);
    }

    @Override
    public int countFollowersByMemberId(Integer memberId) {
        return followJpaRepository.countByFollowingIdAndActivateYnTrue(memberId);
    }

    @Override
    public Map<Integer, Integer> countFollowersByMemberIds(List<Integer> memberIds) {
        List<Object[]> results = followJpaRepository.countFollowersByMemberIdIn(memberIds);

        Map<Integer, Integer> followerCountMap = new HashMap<>();
        for (Object[] result : results) {
            Integer memberId = (Integer) result[0];
            Integer count = ((Number) result[1]).intValue();
            followerCountMap.put(memberId, count);
        }

        return followerCountMap;
    }

    @Override
    public Boolean isFollowed(Integer followerId, Integer followingId) {
        return followJpaRepository.existsByFollowerIdAndFollowingIdAndActivateYnTrue(followerId, followingId);
    }
}
