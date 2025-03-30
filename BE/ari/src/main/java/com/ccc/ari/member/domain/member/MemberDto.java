package com.ccc.ari.member.domain.member;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

/*
 TODO : 추후 구현 예정
 */
@Getter
@Builder
public class MemberDto {
    private Integer memberId;
    private String nickname;
    private String bio;
    private String profileImageUrl;
    private String email;
    private String instagramId;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime registeredAt;
}
