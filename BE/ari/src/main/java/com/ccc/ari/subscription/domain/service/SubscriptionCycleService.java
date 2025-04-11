package com.ccc.ari.subscription.domain.service;

import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.repository.SubscriptionCycleRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SubscriptionCycleService {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionCycleRepository subscriptionCycleRepository;
    private static final Logger logger = LoggerFactory.getLogger(SubscriptionCycleService.class);

    public void startFirstSubscriptionCycle(Subscription subscription) {
        // 도메인 객체를 통한 사이클 생성
        SubscriptionCycle newCycle = subscription.startFirstCycle();
        logger.info("구독(ID: {})의 첫 구독 사이클이 시작되었습니다.", subscription.getSubscriptionId().getValue());
        SubscriptionCycle savedCycle = subscriptionCycleRepository.save(newCycle);
        logger.info("첫 구독 사이클 도메인 객체 저장 완료 - 사이클 ID: {}, 구독 ID: {}, {} ~ {}",
                savedCycle.getSubscriptionCycleId().getValue(),
                savedCycle.getSubscriptionId().getValue(),
                savedCycle.getStartedAt(), savedCycle.getEndedAt());
    }

    public void startNewSubscriptionCycle(Subscription subscription) {
        // 구독의 가장 최근 구독 사이클 가져오기
        SubscriptionCycle latestCycle = subscriptionCycleRepository.getLatestCycle(subscription.getSubscriptionId());

        SubscriptionCycle newCycle = subscription.startNewCycle(latestCycle);
        logger.info("구독(ID: {})의 새로운 구독 사이클이 시작되었습니다.", subscription.getSubscriptionId().getValue());
        SubscriptionCycle savedCycle = subscriptionCycleRepository.save(newCycle);
        logger.info("새 구독 사이클 도메인 객체 저장 완료 - 사이클 ID: {}, 구독 ID: {}, {} ~ {}",
                savedCycle.getSubscriptionCycleId().getValue(),
                savedCycle.getSubscriptionId().getValue(),
                savedCycle.getStartedAt(), savedCycle.getEndedAt());
    }
}
