package com.ccc.ari.member.infrastructure.adapter;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.infrastructure.repository.member.JpaMemberRepository;
import com.ccc.ari.member.mapper.MemberMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MemberClientImpl implements MemberClient {

    private final JpaMemberRepository jpaMemberJpaRepository;

    @Override
    public String getNicknameByMemberId(Integer memberId) {
        MemberEntity member = jpaMemberJpaRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(ErrorCode.MEMBER_NOT_FOUND));

        return member.getNickname();
    }

    @Override
    public MemberDto getMemberByMemberId(Integer memberId) {
        MemberEntity member = jpaMemberJpaRepository.findByMemberId(memberId)
                .orElseThrow(() -> new ApiException(ErrorCode.MEMBER_NOT_FOUND));

        return MemberMapper.toDto(member);
    }

}