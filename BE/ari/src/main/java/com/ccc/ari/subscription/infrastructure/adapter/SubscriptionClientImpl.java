package com.ccc.ari.subscription.infrastructure.adapter;

import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class SubscriptionClientImpl implements SubscriptionClient {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionCycleRepository subscriptionCycleRepository;

    @Override
    public Optional<List<Subscription>> getSubscriptionInfo(Integer memberId) {
        return subscriptionRepository.findListByMemberId(memberId);
    }
}
