package com.ccc.ari.community.infrastructure.fantalk.repository;

import com.ccc.ari.community.application.fantalk.repository.FantalkRepository;
import com.ccc.ari.community.domain.fantalk.entity.Fantalk;
import com.ccc.ari.community.infrastructure.fantalk.entity.FantalkJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

/**
 * 팬톡 리포지토리 구현체
 */
@Repository
@RequiredArgsConstructor
public class FantalkRepositoryImpl implements FantalkRepository {

    private final FantalkJpaRepository fantalkJpaRepository;

    @Override
    public Fantalk saveFantalk(Fantalk fantalk) {
        // 1. 도메인 엔티티를 JPA 엔티티로 변환합니다.
        FantalkJpaEntity jpaEntity = FantalkJpaEntity.fromDomain(fantalk);

        // 2. JPA 리포지토리를 통해 팬톡을 저장합니다.
        FantalkJpaEntity savedEntity = fantalkJpaRepository.save(jpaEntity);

        // 3. 저장된 JPA 엔티티를 다시 도메인 엔티티로 변환하여 반환합니다.
        return savedEntity.toDomain();
    };
}
