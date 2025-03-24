package com.ccc.ari.global.oauth;

import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Map;

public class GoogleUserMapper implements ProviderUserMapper{
    @Override
    public Map<String, Object> mapAttributes(OAuth2User oauth2User) {
        return Map.of(
                "email", oauth2User.getAttribute("email"),
                "name", oauth2User.getAttribute("name"),
                "profileImageUrl", oauth2User.getAttribute("picture")
        );
    }
}