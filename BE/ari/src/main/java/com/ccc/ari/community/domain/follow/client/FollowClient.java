package com.ccc.ari.community.domain.follow.client;

import com.ccc.ari.community.domain.like.LikeType;

import java.util.List;
import java.util.Map;

/**
 * 팔로우 도메인에 접근하기 위한 클라이언트 인터페이스
 */
public interface FollowClient {
    // 팔로잉 목록 조회
    List<FollowingDto> getFollowingsByMemberId(Integer memberId);

    // 팔로워 목록 조회
    List<FollowerDto> getFollowersByMemberId(Integer memberId);

    // 팔로잉 수 조회
    int countFollowingsByMemberId(Integer memberId);

    // 팔로워 수 조회
    int countFollowersByMemberId(Integer memberId);

    // 여러 회원의 팔로워 수를 한 번에 조회하는 메서드 추가
    Map<Integer, Integer> countFollowersByMemberIds(List<Integer> memberIds);

    // 특정 회원이 다른 회원을 팔로우했는지 확인
    Boolean isFollowed(Integer followerId, Integer followingId);
}
