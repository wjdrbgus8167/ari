package com.ccc.ari.global.oauth;

import java.util.Map;
import java.util.Optional;

public class ProviderUserMapperFactory {
    private static final Map<String, ProviderUserMapper> MAPPERS = Map.of(
            "google", new GoogleUserMapper()
    );

    public static ProviderUserMapper getMapper(String registrationId) {
        return Optional.ofNullable(MAPPERS.get(registrationId))
                .orElseThrow(() -> new IllegalArgumentException("지원하지 않는 OAuth2 제공자입니다: " + registrationId));
    }
}