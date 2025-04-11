package com.ccc.ari.member.domain.client;

import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.member.domain.member.MemberEntity;

import java.util.List;

public interface MemberClient {
    // Member의 닉네임 조회
    String getNicknameByMemberId(Integer memberId);
    MemberDto  getMemberByMemberId(Integer memberId);

    // 회원 검색
    List<MemberDto> searchMembersByKeyword(String query);

    // 프로필 이미지 가져오기
    String getProfileImageUrlByMemberId(Integer memberId);

    MemberEntity getMemberEntityByMemberId(Integer memberId);
}
