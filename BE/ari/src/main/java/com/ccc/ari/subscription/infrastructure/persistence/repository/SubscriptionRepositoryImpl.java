package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.application.repository.SubscriptionRepository;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class SubscriptionRepositoryImpl implements SubscriptionRepository {

    private final SubscriptionJpaRepository subscriptionJpaRepository;

    @Override
    public void save(SubscriptionEntity subscriptionEntity) {
        subscriptionJpaRepository.save(subscriptionEntity);
    };
}