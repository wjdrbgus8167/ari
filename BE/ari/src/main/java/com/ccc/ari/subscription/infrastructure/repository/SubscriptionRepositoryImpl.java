package com.ccc.ari.subscription.infrastructure.repository;

import com.ccc.ari.subscription.application.repository.SubscriptionRepository;
import com.ccc.ari.subscription.infrastructure.entity.SubscriptionEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class SubscriptionRepositoryImpl implements SubscriptionRepository {

    private final SubscriptionJpaRepository subscriptionJpaRepository;


}