package com.ccc.ari.member.ui;

import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.global.util.CookieUtils;
import com.ccc.ari.member.application.service.MemberService;
import com.ccc.ari.member.application.command.MemberLoginCommand;
import com.ccc.ari.member.application.command.MemberRegisterCommand;
import com.ccc.ari.member.application.command.RefreshAccessTokenCommand;
import com.ccc.ari.member.domain.AuthTokens;
import com.ccc.ari.member.ui.reuquest.MemberLoginRequest;
import com.ccc.ari.member.ui.reuquest.MemberRegisterRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/v1/auth")
public class MemberController {

    private final MemberService memberService;

    /**
     * 일반 사용자 이메일 회원가입
     */
    @PostMapping("/members/register")

    public ApiUtils.ApiResponse<?> memberRegister(@RequestBody @Valid MemberRegisterRequest request){

        MemberRegisterCommand command = MemberRegisterCommand.builder()
                .email(request.getEmail())
                .password(request.getPassword())
                .nickname(request.getNickname())
                .build();

        memberService.memberRegister(command);

        return ApiUtils.success("회원가입이 완료되었습니다.");

    }

    /**
     *  일반 사용자 이메일 로그인
     */
    @PostMapping("/members/login")
    public ApiUtils.ApiResponse<?> memberLogin(
            @RequestBody @Valid MemberLoginRequest request,
            HttpServletResponse response
    ) {

        MemberLoginCommand command = MemberLoginCommand.builder()
                .email(request.getEmail())
                .password(request.getPassword())
                .build();

        AuthTokens tokens = memberService.memberLogin(command);
        CookieUtils.addAccessTokenCookie(response, tokens.accessToken());
        CookieUtils.addRefreshTokenCookie(response, tokens.refreshToken());

        return ApiUtils.success("로그인이 완료되었습니다.");

    }


    @PostMapping("/token/refresh")
    public ApiUtils.ApiResponse<?> refreshAccessToken(
            HttpServletRequest request,
            HttpServletResponse response
    ) {
        RefreshAccessTokenCommand command = RefreshAccessTokenCommand.builder()
                .refreshToken(CookieUtils.getRefreshToken(request))
                .build();

        AuthTokens newTokens = memberService.refreshAccessToken(command);

        // 새로운 토큰 쿠키에 담기
        CookieUtils.addAccessTokenCookie(response, newTokens.accessToken());
        CookieUtils.addRefreshTokenCookie(response, newTokens.refreshToken());

        return ApiUtils.success("토큰이 재발급 되었습니다.");
    }


}
