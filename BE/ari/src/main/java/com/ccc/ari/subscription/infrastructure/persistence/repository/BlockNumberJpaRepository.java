package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.infrastructure.persistence.entity.BlockNumberEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BlockNumberJpaRepository extends JpaRepository<BlockNumberEntity, String> {
}
