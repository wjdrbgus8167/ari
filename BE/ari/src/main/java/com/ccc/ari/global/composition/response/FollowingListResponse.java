package com.ccc.ari.global.composition.response;

import com.ccc.ari.community.domain.follow.client.FollowingDto;
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

    public static FollowingListResponse from(List<FollowingDto> followings, int followingCount, Map<Integer, Integer> followerCountMap) {
        List<FollowingMember> followingMembers = followings.stream()
                .map(following -> {
                        Integer followingId = following.getFollowingId();
                        int followerCount = followerCountMap.getOrDefault(followingId, 0);

                        return FollowingMember.builder()
                            .memberId(following.getFollowingId())
                            .memberName("더미 사용자 이름")
                            .profileImageUrl("더미 프로필 이미지 URL")
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
