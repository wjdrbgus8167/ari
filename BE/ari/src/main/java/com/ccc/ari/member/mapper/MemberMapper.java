package com.ccc.ari.member.mapper;

import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.member.domain.member.MemberEntity;

public class MemberMapper {

    public static MemberDto toDto(MemberEntity entity) {

        return MemberDto.builder()
                .memberId(entity.getMemberId())
                .nickname(entity.getNickname())
                .bio(entity.getBio())
                .profileImageUrl(entity.getProfileImageUrl())
                .email(entity.getEmail())
                .instagramId(entity.getInstagramId())
                .registeredAt(entity.getRegisteredAt())
                .build();
    }
}
