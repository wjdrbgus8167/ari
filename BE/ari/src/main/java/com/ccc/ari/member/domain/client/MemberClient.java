package com.ccc.ari.member.domain.client;

import com.ccc.ari.member.domain.member.MemberDto;

public interface MemberClient {
    // Member의 닉네임 조회
    String getNicknameByMemberId(Integer memberId);
    MemberDto  getMemberByMemberId(Integer memberId);
}
