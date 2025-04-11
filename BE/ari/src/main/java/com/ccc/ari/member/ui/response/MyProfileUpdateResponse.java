package com.ccc.ari.member.ui.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class MyProfileUpdateResponse {
    private String nickname;
    private String bio;
    private String instagramId;
    private String profileImageUrl;

    @Builder
    public MyProfileUpdateResponse(String nickname, String bio, String instagramId, String profileImageUrl) {
        this.nickname = nickname;
        this.bio = bio;
        this.instagramId = instagramId;
        this.profileImageUrl = profileImageUrl;
    }
}
