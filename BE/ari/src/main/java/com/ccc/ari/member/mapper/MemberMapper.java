package com.ccc.ari.member.mapper;

import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.member.domain.member.MemberEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
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

    public static MemberEntity toEntity(MemberDto dto) {
       return MemberEntity.builder()
               .memberId(dto.getMemberId())
               .nickname(dto.getNickname())
               .bio(dto.getBio())
               .registeredAt(dto.getRegisteredAt())
               .email(dto.getEmail())
               .instagramId(dto.getInstagramId())
               .profileImageUrl(dto.getProfileImageUrl())
               .build();
    }
}
