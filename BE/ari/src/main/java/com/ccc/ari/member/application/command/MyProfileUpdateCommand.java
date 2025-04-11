package com.ccc.ari.member.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Getter
@NoArgsConstructor
public class MyProfileUpdateCommand {

    private String nickname;
    private String bio;
    private String instagramId;
    private Integer memberId;
    private MultipartFile profileImage;

    @Builder
    public MyProfileUpdateCommand(String nickname, String bio, String instagramId, MultipartFile profileImage
    , Integer memberId) {

        this.nickname = nickname;
        this.bio = bio;
        this.instagramId = instagramId;
        this.profileImage = profileImage;
        this.memberId = memberId;
    }

}
