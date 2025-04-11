package com.ccc.ari.member.mapper;

import com.ccc.ari.member.domain.refreshToken.RefreshToken;
import com.ccc.ari.member.domain.refreshToken.RefreshTokenEntity;

public class RefreshTokenMapper {

    public static RefreshTokenEntity mapToEntity(RefreshToken refreshToken) {
        return RefreshTokenEntity.builder()
                .email(refreshToken.getEmail())
                .userId(refreshToken.getUserId())
                .refreshToken(refreshToken.getRefreshToken())
                .expiration(refreshToken.getExpiration())
                .build();
    }
}