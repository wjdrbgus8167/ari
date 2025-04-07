package com.ccc.ari.subscription.infrastructure.adapter;

import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class SubscriptionClientImpl implements SubscriptionClient {

    private final SubscriptionRepository subscriptionRepository;

    @Override
    public Optional<List<Subscription>> getSubscriptionInfo(Integer memberId) {
        return subscriptionRepository.findListByMemberId(memberId);
    }

    @Override
    public Boolean hasActiveSubscription(Integer memberId, Integer subscriptionPlanId) {
        return subscriptionRepository.findActiveSubscription(memberId, subscriptionPlanId).isPresent();
    }

    @Override
    public Integer countActiveSubscribersByPlanId(Integer subscriptionPlanId) {
        return subscriptionRepository.countBySubscriptionPlanIdAndActivateYnIsTrue(subscriptionPlanId);
    }
}
