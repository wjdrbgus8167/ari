package com.ccc.ari.global.oauth;

import com.ccc.ari.global.config.AppConfig;
import com.ccc.ari.global.jwt.JwtTokenProvider;
import com.ccc.ari.global.util.CookieUtils;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.infrastructure.repository.member.JpaMemberRepository;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import java.io.IOException;

@AllArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    private final JwtTokenProvider jwtTokenProvider;
    private final JpaMemberRepository jpaMemberRepository;
    private final AppConfig appConfig;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        OAuth2UserDetails userDetails = (OAuth2UserDetails) authentication.getPrincipal();

        MemberEntity member = jpaMemberRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new IllegalArgumentException("해당 사용자가 존재하지 않습니다."));

        String accessToken = jwtTokenProvider.createAccessToken(member.getMemberId(), member.getEmail());
        String refreshToken = jwtTokenProvider.createRefreshToken(member.getMemberId(), member.getEmail());

        CookieUtils.addRefreshTokenCookie(response, refreshToken);
        CookieUtils.addAccessTokenCookie(response, accessToken);

        response.sendRedirect("https://" + appConfig.getDomain() +"/oauth/success");
    }
}
