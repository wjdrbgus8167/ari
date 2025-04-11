package com.ccc.ari.subscription.infrastructure.adapter;

import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.client.SubscriptionCompositionClient;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class SubscriptionCompositionClientImpl implements SubscriptionCompositionClient {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionCycleRepository subscriptionCycleRepository;

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

    @Override
    public List<Subscription> getSubscriptionBySubscriptionPlanId(Integer subscriptionPlanId) {
        return subscriptionRepository.findAllBySubscriptionPlanIdAndActivateYnTrue(subscriptionPlanId);
    }

    @Override
    public List<Subscription> getRegularSubscription(Integer subscriptionPlanId,LocalDateTime start, LocalDateTime end) {
        return subscriptionRepository.findAllBySubscriptionPlanIdAndSubscribedAtBetweenAndActivateYnTrue(subscriptionPlanId,start,end);
    }

    @Override
    public Optional<Subscription> getSubscription(Integer subscriptionId) {
        return subscriptionRepository.findSubscription(subscriptionId);
    }


}
