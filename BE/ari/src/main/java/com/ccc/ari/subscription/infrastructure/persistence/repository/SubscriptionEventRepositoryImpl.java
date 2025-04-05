package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.global.type.EventType;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.domain.repository.SubscriptionEventRepository;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEventEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class SubscriptionEventRepositoryImpl implements SubscriptionEventRepository {

    private final SubscriptionEventJpaRepository subscriptionEventJpaRepository;


    @Override
    public boolean existsBySubscriptionEventIdAndEventTypeP(String subscriptionEventId) {
        return subscriptionEventJpaRepository.existsBySubscriptionEventIdAndEventType(subscriptionEventId, EventType.P);
    }

    @Override
    public boolean existsBySubscriptionEventIdAndEventTypeS(String subscriptionEventId) {
        return subscriptionEventJpaRepository.existsBySubscriptionEventIdAndEventType(subscriptionEventId, EventType.S);
    }

    @Override
    public void save(String subscriptionEventId, EventType eventType, Integer subscriberId, PlanType planType) {
        subscriptionEventJpaRepository.save(
                new SubscriptionEventEntity(subscriptionEventId, eventType, subscriberId, planType));
    }
}
