package com.ccc.ari.member.domain;

import lombok.Builder;

@Builder
public record AuthTokens(
        String accessToken,
        String refreshToken) {

}
