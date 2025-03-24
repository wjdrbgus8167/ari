package com.ccc.ari.global.oauth;

import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Map;

public interface ProviderUserMapper {
    Map<String, Object> mapAttributes(OAuth2User oauth2User);
}
