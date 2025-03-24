package com.ccc.ari.global.oauth;

import com.ccc.ari.member.domain.member.MemberEntity;
import lombok.AllArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.Collections;
import java.util.Map;

@AllArgsConstructor
public class OAuth2UserDetails implements OAuth2User, UserDetails {
    private final MemberEntity member;

    @Override
    public String getPassword() {
        return member.getPassword();
    }

    @Override
    public String getUsername() {
        return member.getEmail();
    }

    @Override
    public Map<String, Object> getAttributes() {
        return Map.of();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singleton(() -> "ROLE_MEMBER");
    }

    @Override
    public String getName() {
        return String.valueOf(member.getMemberId());
    }

}