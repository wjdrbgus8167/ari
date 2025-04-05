package com.ccc.ari.member.domain.client;

import com.ccc.ari.member.domain.member.MemberDto;

import java.util.List;

public interface MemberClient {
    // Member의 닉네임 조회
    String getNicknameByMemberId(Integer memberId);
    MemberDto  getMemberByMemberId(Integer memberId);

    // 회원 검색
    List<MemberDto> searchMembersByKeyword(String query);
}
