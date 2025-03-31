package com.ccc.ari.global.composition.service;

import com.ccc.ari.community.domain.follow.client.FollowClient;
import com.ccc.ari.community.domain.follow.client.FollowerDto;
import com.ccc.ari.community.domain.follow.client.FollowingDto;
import com.ccc.ari.global.composition.response.FollowerListResponse;
import com.ccc.ari.global.composition.response.FollowingListResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FollowListService {

    private final FollowClient followClient;
    private final MemberClient memberClient;

    public FollowingListResponse getFollowingList(Integer memberId) {
        // 1. memberId가 팔로우 하는 팔로잉 목록을 조회합니다.
        List<FollowingDto> followings = followClient.getFollowingsByMemberId(memberId);

        // 2. 팔로잉 수를 조회합니다.
        int followingCount = followClient.countFollowingsByMemberId(memberId);

        // 3. 팔로잉 목록에서 회원 ID를 추출합니다.
        List<Integer> followingMemberIds = followings.stream()
                .map(FollowingDto::getFollowingId)
                .toList();

        // 4. 한 번에 모든 팔로잉 회원의 팔로워 수를 조회합니다.
        Map<Integer, Integer> followerCountMap = followClient.countFollowersByMemberIds(followingMemberIds);

        // 5. 팔로잉 회원들의 정보를 조회합니다.
        // TODO: N+1 문제 해결
        Map<Integer, MemberDto> memberInfoMap = new HashMap<>();
        for (Integer id : followingMemberIds) {
            MemberDto memberDto = memberClient.getMemberByMemberId(id);
            memberInfoMap.put(id, memberDto);
        }

        // 6. 응답 객체를 구성합니다.
        return FollowingListResponse.from(followings, followingCount, followerCountMap, memberInfoMap);
    }

    public FollowerListResponse getFollowerList(Integer memberId) {
        // 1. memberId를 팔로우 하는 팔로워 목록을 조회합니다.
        List<FollowerDto> followers = followClient.getFollowersByMemberId(memberId);

        // 2. 팔로워 수를 조회합니다.
        int followerCount = followClient.countFollowersByMemberId(memberId);

        // 3. 팔로워 목록에서 회원 ID를 추출합니다.
        List<Integer> followerMemberIds = followers.stream()
                .map(FollowerDto::getFollowerId)
                .toList();

        // 4. 한 번에 모든 팔로워 회원의 팔로워 수를 조회합니다.
        Map<Integer, Integer> followerCountMap = followClient.countFollowersByMemberIds(followerMemberIds);

        // 5. 팔로워 회원들의 정보를 조회합니다.
        // TODO: N+1 문제 해결
        Map<Integer, MemberDto> memberInfoMap = new HashMap<>();
        for (Integer id : followerMemberIds) {
            MemberDto memberDto = memberClient.getMemberByMemberId(id);
            memberInfoMap.put(id, memberDto);
        }

        // 6. 응답 객체를 구성합니다.
        return FollowerListResponse.from(followers, followerCount, followerCountMap, memberInfoMap);
    }
}
