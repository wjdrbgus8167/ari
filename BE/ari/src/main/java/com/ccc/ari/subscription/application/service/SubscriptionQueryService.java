package com.ccc.ari.subscription.application.service;

import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.application.command.GetMyRegularCyclesCommand;
import com.ccc.ari.subscription.application.response.GetMyRegularCyclesResponse;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.exception.RegularPlanNotFoundException;
import com.ccc.ari.subscription.domain.exception.RegularSubscriptionNotFoundException;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionPlanRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SubscriptionQueryService {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository subscriptionPlanRepository;
    private final SubscriptionCycleRepository subscriptionCycleRepository;

    public List<GetMyRegularCyclesResponse> getRegularCycles(GetMyRegularCyclesCommand command) {
        // 1. 정기 구독 플랜 ID 조회
        SubscriptionPlan regularPlan = subscriptionPlanRepository
                .findSubscriptionPlanByPlanType(PlanType.R)
                .orElseThrow(RegularPlanNotFoundException::new);

        // 2. 정기 구독 목록 조회
        List<Subscription> subscriptions = subscriptionRepository
                .findListByMemberIdAndSubscriptionPlanId(command.getMemberId(),
                                                         regularPlan.getSubscriptionPlanId().getValue())
                .orElseThrow(RegularSubscriptionNotFoundException::new);

        // 2. 사용자의 정기 구독 목록 조회 후 각 구독의 구독 사이클 목록 조회
        return subscriptions.stream()
                .flatMap(subscription -> subscriptionCycleRepository
                        .getSubscriptionCycleList(subscription.getSubscriptionId())
                        .stream()
                        .map(this::mapToResponse))
                .collect(Collectors.toList());
    }

    private GetMyRegularCyclesResponse mapToResponse(SubscriptionCycle cycle) {
        return GetMyRegularCyclesResponse.builder()
                .cycleId(cycle.getSubscriptionCycleId().getValue())
                .startedAt(cycle.getStartedAt())
                .endedAt(cycle.getEndedAt())
                .build();
    }
}
