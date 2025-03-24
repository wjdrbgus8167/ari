package com.ccc.ari.global.security;

import com.ccc.ari.global.jwt.JwtTokenProvider;
import com.ccc.ari.global.util.CookieUtils;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService customUserDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        try {
            CookieUtils.getAccessToken(request).ifPresent(accessToken -> {
                // access token이 유효한 경우 인증
                String email = jwtTokenProvider.getEmail(accessToken);
                UserDetails userDetails = customUserDetailsService.loadUserByUsername(email);
                Authentication authentication = new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities()
                );
                SecurityContextHolder.getContext().setAuthentication(authentication);
            });

        } catch (ExpiredJwtException e) {
            request.setAttribute("expiredTokenException", e);
        } catch (Exception e) {
            request.setAttribute("invalidTokenException", e);
        }

        filterChain.doFilter(request, response);

    }
}
