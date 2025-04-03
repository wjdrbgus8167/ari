package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionPlanEntity;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SubscriptionPlanJpaRepository extends JpaRepository<SubscriptionPlanEntity, Integer> {

    Optional<SubscriptionPlanEntity> findByPlanType(@NotNull PlanType planType);

    Optional<SubscriptionPlanEntity> findByArtistId(Integer artistId);
}
