package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEventEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SubscriptionEventJpaRepository extends JpaRepository<SubscriptionEventEntity, String> {


}
