package com.ccc.ari.global.composition.response;

import com.ccc.ari.community.domain.follow.client.FollowerDto;
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

    public static FollowerListResponse from(List<FollowerDto> followers, int followerCount, Map<Integer, Integer> followerCountMap) {
        List<FollowerMember> followerMembers = followers.stream()
                .map(follower -> {
                    Integer followerId = follower.getFollowerId();
                    int memberFollowerCount = followerCountMap.getOrDefault(followerId, 0);

                    return FollowerMember.builder()
                            .memberId(followerId)
                            .memberName("더미 사용자 이름")
                            .profileImageUrl("더미 프로필 이미지 URL")
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
