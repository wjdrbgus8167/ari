package com.ccc.ari.member.domain.refreshToken;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;
import org.springframework.data.redis.core.index.Indexed;

@Getter
@RedisHash(value = "refresh_token")
public class RefreshTokenEntity {

    @Id
    private String email;

    @Indexed
    private Integer userId;

    @Indexed
    private String refreshToken;

    @TimeToLive
    private long expiration;

    @Builder
    public RefreshTokenEntity(String email, Integer userId, String refreshToken, long expiration) {
        this.email = email;
        this.userId = userId;
        this.refreshToken = refreshToken;
        this.expiration = expiration;
    }
}
