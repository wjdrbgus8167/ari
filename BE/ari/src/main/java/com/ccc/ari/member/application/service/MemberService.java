package com.ccc.ari.member.application.service;

import com.ccc.ari.event.eventPublisher.SpringEventPublisher;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.jwt.JwtTokenProvider;
import com.ccc.ari.member.application.command.MemberLoginCommand;
import com.ccc.ari.member.application.command.MemberRegisterCommand;
import com.ccc.ari.member.application.command.RefreshAccessTokenCommand;
import com.ccc.ari.member.domain.AuthTokens;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.domain.refreshToken.RefreshToken;
import com.ccc.ari.member.domain.refreshToken.RefreshTokenEntity;
import com.ccc.ari.member.event.MemberRegisterAndFantalkCreatedEvent;
import com.ccc.ari.member.infrastructure.repository.member.JpaMemberRepository;
import com.ccc.ari.member.infrastructure.repository.refreshtoken.RefreshTokenRepository;
import com.ccc.ari.member.mapper.RefreshTokenMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Transactional(readOnly = true)
@AllArgsConstructor
@Service
@Slf4j
public class MemberService {

    private final JpaMemberRepository jpaMemberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final RefreshTokenRepository refreshTokenRepository;
    private final SpringEventPublisher eventPublisher;
    /**
     * 일반 사용자 회원가입
     */
    @Transactional
    public void memberRegister(MemberRegisterCommand command){
        // 이메일 중복 체크
        if(jpaMemberRepository.findByEmail(command.getEmail()).isPresent()){
            throw new ApiException(ErrorCode.EMAIL_ALREADY_IN_USE);
        }

        MemberEntity registeredMember = jpaMemberRepository.save(MemberEntity.builder()
                .email(command.getEmail())
                .password(passwordEncoder.encode(command.getPassword()))
                .nickname(command.getNickname())
                .registeredAt(LocalDateTime.now())
                .provider("")
                .build()
        );
        log.info("회원가입이 완료되었습니다: {}", registeredMember.getMemberId());
        log.info("팬톡 채널 생성 이벤트를 실행합니다");
        eventPublisher.publish(MemberRegisterAndFantalkCreatedEvent.builder()
                .memberId(registeredMember.getMemberId())
                .build());
    }

    /**
     *  일반 사용자 로그인 - access token(쿠키), refresh token(쿠키) 발급
     */
    public AuthTokens memberLogin(MemberLoginCommand command) {
        MemberEntity memberEntity = jpaMemberRepository.findByEmail(command.getEmail())
                .orElseThrow(() -> new ApiException(ErrorCode.MEMBER_NOT_FOUND));

        if (!passwordEncoder.matches(command.getPassword(), memberEntity.getPassword())) {
            throw new ApiException(ErrorCode.INVALID_PASSWORD);
        }

        String accessToken = jwtTokenProvider.createAccessToken(memberEntity.getMemberId(), memberEntity.getEmail());
        String refreshToken = jwtTokenProvider.createRefreshToken(memberEntity.getMemberId(), memberEntity.getEmail());
        saveRefreshToken(RefreshToken.builder()
                .email(memberEntity.getEmail())
                .userId(memberEntity.getMemberId())
                .refreshToken(refreshToken)
                .expiration(jwtTokenProvider.getRefreshExpiration())
                .build()
        );

        return AuthTokens.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }



    /**
     *  refresh token 저장
     */
    public void saveRefreshToken(RefreshToken refreshToken) {
        refreshTokenRepository.save(RefreshTokenMapper.mapToEntity(refreshToken));
    }

    /**
     * access token 재발급
     */
    @Transactional
    public AuthTokens refreshAccessToken(RefreshAccessTokenCommand command) {
        String oldRefreshToken = command.getRefreshToken()
                .orElseThrow(() -> new ApiException(ErrorCode.MISSING_REFRESH_TOKEN));

        String email = jwtTokenProvider.getEmail(oldRefreshToken);
        int userId = jwtTokenProvider.getUserId(oldRefreshToken);

        RefreshTokenEntity refreshTokenEntity = refreshTokenRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(ErrorCode.INVALID_TOKEN));

        if (!refreshTokenEntity.getRefreshToken().equals(oldRefreshToken)
                || !refreshTokenEntity.getUserId().equals(userId)) {
            throw new ApiException(ErrorCode.INVALID_TOKEN);
        }

        //새 토큰들 발급
        String newAccessToken = jwtTokenProvider.createAccessToken(userId, email);
        String newRefreshToken = jwtTokenProvider.createRefreshToken(userId, email);

        //Redis 갱신
        saveRefreshToken(RefreshToken.builder()
                .email(email)
                .userId(userId)
                .refreshToken(newRefreshToken)
                .expiration(jwtTokenProvider.getRefreshExpiration())
                .build());

        return AuthTokens.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }


}
