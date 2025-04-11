package com.ccc.ari.global.composition.response.mypage;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MyProfileResponse {

    private Integer memberId;
    private String nickName;
    private String instagram;
    private String bio;
    private String profileImageUrl;
    private Integer followerCount;
    private Integer followingCount;
}
