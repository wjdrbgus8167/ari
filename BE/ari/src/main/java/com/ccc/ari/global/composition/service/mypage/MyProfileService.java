package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.community.domain.follow.client.FollowClient;
import com.ccc.ari.community.domain.follow.client.FollowerDto;
import com.ccc.ari.global.composition.response.mypage.MyProfileResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MyProfileService {

    private final MemberClient memberClient;
    private final FollowClient followClient;

    public MyProfileResponse getMyProfile(Integer memberId) {

        MemberDto member = memberClient.getMemberByMemberId(memberId);
        Integer followerCount = followClient.countFollowersByMemberId(memberId);
        Integer followingCount = followClient.countFollowingsByMemberId(memberId);

        return MyProfileResponse.builder()
                .memberId(memberId)
                .nickName(member.getNickname())
                .bio(member.getBio())
                .profileImageUrl(member.getProfileImageUrl())
                .instagram(member.getInstagramId())
                .followerCount(followerCount)
                .followingCount(followingCount)
                .build();
    }
}
