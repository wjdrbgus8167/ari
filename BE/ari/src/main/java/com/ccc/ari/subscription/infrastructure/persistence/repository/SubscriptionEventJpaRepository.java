package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.global.type.EventType;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEventEntity;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.support.SimpleJpaRepository;

public interface SubscriptionEventJpaRepository extends JpaRepository<SubscriptionEventEntity, String> {

    boolean existsBySubscriptionEventIdAndEventType(String subscriptionEventId, EventType eventType);
}
