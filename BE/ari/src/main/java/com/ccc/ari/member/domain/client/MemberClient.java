package com.ccc.ari.member.domain.client;

public interface MemberClient {
    // Member의 닉네임 조회
    String getNicknameByMemberId(Integer memberId);
}
