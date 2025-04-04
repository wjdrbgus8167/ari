package com.ccc.ari.subscription.infrastructure.persistence.repository;

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
    public boolean existsBySubscriptionEventId(String subscriptionEventId) {
        return subscriptionEventJpaRepository.existsById(subscriptionEventId);
    }

    @Override
    public void save(String subscriptionEventId, Integer subscriberId, PlanType eventType) {
        subscriptionEventJpaRepository.save(new SubscriptionEventEntity(subscriptionEventId, subscriberId, eventType));
    }
}
