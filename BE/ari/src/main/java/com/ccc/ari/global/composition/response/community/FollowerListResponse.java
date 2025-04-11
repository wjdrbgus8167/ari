package com.ccc.ari.global.composition.response.community;

import com.ccc.ari.community.domain.follow.client.FollowerDto;
import com.ccc.ari.member.domain.member.MemberDto;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.Map;

/**
 * 팔로워 목록 조회 응답 DTO
 */
@Getter
@Builder
public class FollowerListResponse {

    private List<FollowerMember> followers;
    private int followerCount;

    public static FollowerListResponse from(List<FollowerDto> followers, int followerCount, Map<Integer, Integer> followerCountMap, Map<Integer, MemberDto> memberInfoMap) {
        List<FollowerMember> followerMembers = followers.stream()
                .map(follower -> {
                    Integer followerId = follower.getFollowerId();
                    int memberFollowerCount = followerCountMap.getOrDefault(followerId, 0);
                    MemberDto memberInfo = memberInfoMap.get(followerId);

                    return FollowerMember.builder()
                            .memberId(followerId)
                            .memberName(memberInfo.getNickname())
                            .profileImageUrl(memberInfo.getProfileImageUrl())
                            .followerCount(memberFollowerCount)
                            .build();
                })
                .toList();

        return FollowerListResponse.builder()
                .followers(followerMembers)
                .followerCount(followerCount)
                .build();
    }

    @Getter
    @Builder
    public static class FollowerMember {
        private Integer memberId;
        private String memberName;
        private String profileImageUrl;
        private int followerCount;
    }
}
