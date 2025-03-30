package com.ccc.ari.global.composition.infrastructure;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.infrastructure.JpaMemberRepository;
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
}