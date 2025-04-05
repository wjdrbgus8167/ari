package com.ccc.ari.global.composition.response.community;

import com.ccc.ari.community.domain.follow.client.FollowingDto;
import com.ccc.ari.member.domain.member.MemberDto;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.Map;

/**
 * 팔로잉 목록 조회 응답 DTO
 */
@Getter
@Builder
public class FollowingListResponse {

    private List<FollowingMember> followings;
    private int followingCount;

    public static FollowingListResponse from(List<FollowingDto> followings, int followingCount, Map<Integer, Integer> followerCountMap, Map<Integer, MemberDto> memberInfoMap) {
        List<FollowingMember> followingMembers = followings.stream()
                .map(following -> {
                        Integer followingId = following.getFollowingId();
                        int followerCount = followerCountMap.getOrDefault(followingId, 0);
                    MemberDto memberInfo = memberInfoMap.get(followingId);

                        return FollowingMember.builder()
                            .memberId(following.getFollowingId())
                            .memberName(memberInfo.getNickname())
                            .profileImageUrl(memberInfo.getProfileImageUrl())
                            .followerCount(followerCount)
                            .build();
                })
                .toList();

        return FollowingListResponse.builder()
                .followings(followingMembers)
                .followingCount(followingCount)
                .build();
    }

    @Getter
    @Builder
    public static class FollowingMember {
        private Integer memberId;
        private String memberName;
        private String profileImageUrl;
        private int followerCount;
    }
}
