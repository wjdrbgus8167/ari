package com.ccc.ari.member.infrastructure;

import com.ccc.ari.member.domain.refreshToken.RefreshTokenEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface RefreshTokenRepository extends CrudRepository<RefreshTokenEntity, Long> {

    Optional<RefreshTokenEntity> findByEmail(String email);
    RefreshTokenEntity findRefreshTokenEntityByEmail(String email);
}
