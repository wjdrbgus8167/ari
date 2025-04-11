package com.ccc.ari.subscription.infrastructure.adapter;

import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.client.SubscriptionCycleClient;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.domain.vo.SubscriptionId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class SubscriptionCycleClientImpl implements SubscriptionCycleClient {

    private final SubscriptionCycleRepository subscriptionCycleRepository;


    public List<SubscriptionCycle> getSubscriptionCycle(SubscriptionId subscriptionId) {

        List<SubscriptionCycle> cycle = subscriptionCycleRepository.getSubscriptionCycleList(subscriptionId) ;
        return cycle;
    }

    @Override
    public SubscriptionCycle getLatestSubscriptionCycle(SubscriptionId subscriptionId) {
        return subscriptionCycleRepository.getLatestCycle(subscriptionId);
    }

}
