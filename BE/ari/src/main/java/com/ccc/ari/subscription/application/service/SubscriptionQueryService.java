package com.ccc.ari.subscription.application.service;

import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.application.command.GetMyRegularCyclesCommand;
import com.ccc.ari.subscription.application.response.GetMyRegularCyclesResponse;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.exception.ArtistSubscriptionNotFoundException;
import com.ccc.ari.subscription.domain.exception.CycleNotFoundException;
import com.ccc.ari.subscription.domain.exception.RegularPlanNotFoundException;
import com.ccc.ari.subscription.domain.exception.RegularSubscriptionNotFoundException;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionPlanRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import com.ccc.ari.subscription.domain.vo.SubscriptionCycleId;
import com.ccc.ari.subscription.infrastructure.persistence.repository.SubscriptionCycleJpaRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SubscriptionQueryService {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository subscriptionPlanRepository;
    private final SubscriptionCycleRepository subscriptionCycleRepository;
    private final SubscriptionPlanCoordinationService subscriptionPlanCoordinationService;

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Transactional(readOnly = true)
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

    @Transactional(readOnly = true)
    public SubscriptionCycle getRegularSubscriptionCycleByPeriod(Integer subscriberId,
                                                                 LocalDateTime startTime, LocalDateTime endTime) {
        // 1. 정기 구독 플랜 가져오기
        SubscriptionPlan regularPlan =
                subscriptionPlanCoordinationService.getOrCreateRegularPlan(BigDecimal.ONE);
        // 2. 정기 구독 가져오기
        Subscription regularSubscription =
                subscriptionRepository.findActiveSubscription(subscriberId,
                                                              regularPlan.getSubscriptionPlanId().getValue())
                    .orElseThrow(RegularSubscriptionNotFoundException::new);
        // 3. 두 시간의 사이에 사이클이 시작한 사이클 가져오기
        return subscriptionCycleRepository.getSubscriptionCycleByPeriod(regularSubscription.getSubscriptionId(),
                                                                         startTime, endTime)
                        .orElseThrow(() -> new CycleNotFoundException(startTime, endTime));

    }

    @Transactional(readOnly = true)
    public SubscriptionCycle getArtistSubscriptionCycleIdByPeriod(Integer subscriberId, Integer artistId,
                                                                  LocalDateTime startTime, LocalDateTime endTime) {
        // 1. 아티스트 구독 플랜 가져오기
        SubscriptionPlan artistPlan =
                subscriptionPlanCoordinationService.getOrCreateArtistPlan(artistId, BigDecimal.ONE);
        // 2. 아티스트 구독 가져오기
        Subscription artistSubscription =
                subscriptionRepository.findActiveSubscription(subscriberId,
                                                              artistPlan.getSubscriptionPlanId().getValue())
                        .orElseThrow(() -> new ArtistSubscriptionNotFoundException(artistId));
        // 3. 두 시간의 사이에 사이클이 시작한 사이클 가져오기
        return subscriptionCycleRepository.getSubscriptionCycleByPeriod(artistSubscription.getSubscriptionId(),
                                                                        startTime, endTime)
                        .orElseThrow(() -> new CycleNotFoundException(startTime, endTime));
    }

    public SubscriptionCycle getSubscriptionCycleById(Integer subscriptionCycleId) {
        return subscriptionCycleRepository.getSubscriptionCycleById(subscriptionCycleId);
    }
}
