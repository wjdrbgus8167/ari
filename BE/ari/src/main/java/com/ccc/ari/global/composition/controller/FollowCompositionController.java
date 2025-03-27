package com.ccc.ari.global.composition.controller;

import com.ccc.ari.community.domain.follow.client.FollowClient;
import com.ccc.ari.community.domain.follow.client.FollowerDto;
import com.ccc.ari.community.domain.follow.client.FollowingDto;
import com.ccc.ari.global.composition.response.FollowerListResponse;
import com.ccc.ari.global.composition.response.FollowingListResponse;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/follows/members/{memberId}")
@RequiredArgsConstructor
public class FollowCompositionController {

    private final FollowClient followClient;

    @GetMapping("/following/list")
    public ApiUtils.ApiResponse<FollowingListResponse> getFollowingList(@PathVariable Integer memberId) {
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

        // 5. 응답 객체를 구성합니다.
        // TODO: 회원 Client 구현 시 응답 객체 수정하겠습니다.
        FollowingListResponse response = FollowingListResponse.from(followings, followingCount, followerCountMap);

        return ApiUtils.success(response);
    }

    @GetMapping("/follower/list")
    public ApiUtils.ApiResponse<FollowerListResponse> getFollowerList(@PathVariable Integer memberId) {
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

        // 5. 응답 객체를 구성합니다.
        // TODO: 회원 Client 구현 시 응답 객체 수정하겠습니다.
        FollowerListResponse response = FollowerListResponse.from(followers, followerCount, followerCountMap);

        return ApiUtils.success(response);
    }
}
