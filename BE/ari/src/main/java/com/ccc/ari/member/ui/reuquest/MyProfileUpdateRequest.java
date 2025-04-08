package com.ccc.ari.member.ui.reuquest;

import com.ccc.ari.member.application.command.MyProfileUpdateCommand;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Getter
@NoArgsConstructor
public class MyProfileUpdateRequest {

    private String nickname;
    private String bio;
    private String instagramId;

    @Builder
    public MyProfileUpdateRequest(String nickname, String bio, String instagramId) {
        this.nickname = nickname;
        this.bio = bio;
        this.instagramId = instagramId;
    }

    public MyProfileUpdateCommand toCommand(MultipartFile profileImage,Integer memberId) {

        return MyProfileUpdateCommand
                .builder()
                .nickname(nickname)
                .bio(bio)
                .instagramId(instagramId)
                .profileImage(profileImage)
                .memberId(memberId)
                .build();
    }
}
