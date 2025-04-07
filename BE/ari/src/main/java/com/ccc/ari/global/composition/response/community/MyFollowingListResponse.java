package com.ccc.ari.global.composition.response.community;

import com.ccc.ari.community.domain.follow.client.FollowingDto;
import com.ccc.ari.member.domain.member.MemberDto;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.Map;

/**
 * 내 팔로잉 목록 조회 응답 DTO
 */
@Getter
@Builder
public class MyFollowingListResponse {

    private List<FollowingMember> followings;
    private int followingCount;

    public static MyFollowingListResponse from(List<FollowingDto> followings, Integer followingCount,
                                               Map<Integer, Integer> followerCountMap, Map<Integer, MemberDto> memberInfoMap,
                                               Map<Integer, Integer> subscriberCountMap, Map<Integer, Boolean> subscribedYnMap,
                                               Map<Integer, Boolean> artistYnMap) {
        List<FollowingMember> followingMembers = followings.stream()
                .map(following -> {
                        Integer followingId = following.getFollowingId();
                        int followerCount = followerCountMap.getOrDefault(followingId, 0);
                        MemberDto memberInfo = memberInfoMap.get(followingId);
                        Integer subscriberCount = subscriberCountMap.getOrDefault(followingId, 0);
                        Boolean subscribedYn = subscribedYnMap.getOrDefault(followingId, false);
                        Boolean artistYn = artistYnMap.getOrDefault(followingId, false);

                        return FollowingMember.builder()
                            .memberId(following.getFollowingId())
                            .memberName(memberInfo.getNickname())
                            .profileImageUrl(memberInfo.getProfileImageUrl())
                            .followerCount(followerCount)
                            .subscriberCount(subscriberCount)
                            .subscribedYn(subscribedYn)
                            .artistYn(artistYn)
                            .build();
                })
                .toList();

        return MyFollowingListResponse.builder()
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
        private Integer followerCount;
        private Integer subscriberCount;
        private Boolean subscribedYn;
        private Boolean artistYn;
    }
}
