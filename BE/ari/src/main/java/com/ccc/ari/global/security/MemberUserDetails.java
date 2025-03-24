package com.ccc.ari.global.security;

import com.ccc.ari.member.domain.member.MemberEntity;
import lombok.AllArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@AllArgsConstructor
public class MemberUserDetails implements UserDetails {

    private final MemberEntity memberEntity;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singleton(() -> "ROLE_MEMBER");
    }

    @Override
    public String getPassword() {
        return memberEntity.getPassword();
    }

    @Override
    public String getUsername() {
        return memberEntity.getEmail();
    }

    public Integer getMemberId() {
        return memberEntity.getMemberId();
    }

    public String getEmail() { return memberEntity.getEmail();}

    public String getNickname() { return memberEntity.getNickname();}

    public String getProfileImageUrl() {return memberEntity.getProfileImageUrl();}

    public String getProvider(){return memberEntity.getProvider();}

}