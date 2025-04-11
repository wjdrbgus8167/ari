package com.ccc.ari.subscription.application.service;

import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.exception.ArtistPlanNotFoundException;
import com.ccc.ari.subscription.domain.exception.RegularPlanNotFoundException;
import com.ccc.ari.subscription.domain.repository.SubscriptionPlanRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import com.ccc.ari.subscription.domain.service.SubscriptionCycleService;
import com.ccc.ari.subscription.event.OnChainArtistPaymentProcessedEvent;
import com.ccc.ari.subscription.event.OnChainArtistSubscriptionCreatedEvent;
import com.ccc.ari.subscription.event.OnChainRegularPaymentProcessedEvent;
import com.ccc.ari.subscription.event.OnChainRegularSubscriptionCreatedEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OffChainSubscriptionCreateService {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository subscriptionPlanRepository;
    private final SubscriptionCycleService subscriptionCycleService;
    private final SubscriptionPlanCoordinationService subscriptionPlanCoordinationService;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @EventListener
    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createOffChainRegularSubscription(OnChainRegularSubscriptionCreatedEvent event) {
        logger.info("오프체인 정기 구독 생성 이벤트 리스너 실행 시작 - 스레드: {}", Thread.currentThread().getName());
        logger.info("정기 구독 생성 이벤트 수신 - Subscriber ID: {}, Amount: {}", event.getSubscriberId(), event.getAmount());

        // 1. 정기 구독 플랜 객체 가져오기
        SubscriptionPlan regularSubscriptionPlan =
                subscriptionPlanCoordinationService.getOrCreateRegularPlan(event.getAmount());
        logger.info("정기 구독 플랜 엔터티 가져옴 - Plan ID: {}, Price: {}",
                regularSubscriptionPlan.getSubscriptionPlanId().getValue(), regularSubscriptionPlan.getPrice());

        // 2. 활성화 된 구독이 있는지 확인
        subscriptionRepository.findActiveSubscription(event.getSubscriberId(),
                                                      regularSubscriptionPlan.getSubscriptionPlanId().getValue())
                .ifPresentOrElse(activeSubscriptionEntity ->
                                logger.info("이미 사용자(ID: {})의 활성화된 정기 구독이 있습니다.",
                                        activeSubscriptionEntity.getMemberId()),
                        () -> {
                            // 3. 가져온 정기 구독 플랜으로 구독 도메인 객체 생성
                            Subscription subscription = Subscription.builder()
                                    .subscriptionPlanId(regularSubscriptionPlan.getSubscriptionPlanId().getValue())
                                    .memberId(event.getSubscriberId())
                                    .subscribedAt(LocalDateTime.now())
                                    .expiredAt(null)
                                    .activateYn(true)
                                    .build();
                            logger.info("정기 구독 도메인 객체 생성 - Member ID: {}, Plan ID: {}",
                                    subscription.getMemberId(), subscription.getSubscriptionPlanId());

                            // 4. 생성한 구독 도메인 객체 저장
                            Subscription savedSubscription = subscriptionRepository.save(subscription);
                            logger.info("정기 구독 도메인 객체 저장 완료 - 구독 ID: {}, Member ID: {}, Plan ID: {}",
                                    savedSubscription.getSubscriptionId().getValue(),
                                    savedSubscription.getMemberId(),
                                    savedSubscription.getSubscriptionPlanId());

                            // 5. 구독 사이클 시작
                            subscriptionCycleService.startFirstSubscriptionCycle(savedSubscription);
                        });
    }

    @EventListener
    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createOffChainArtistSubscription(OnChainArtistSubscriptionCreatedEvent event) {
        logger.info("아티스트 구독 생성 이벤트 수신 - Subscriber ID: {}, Artist ID: {}, Amount: {}",
                event.getSubscriberId(), event.getArtistId(), event.getAmount());

        // 1. 아티스트 구독 플랜 객체 가져오기
        SubscriptionPlan artistSubscriptionPlan =
                subscriptionPlanCoordinationService.getOrCreateArtistPlan(event.getArtistId(), event.getAmount());
        logger.info("아티스트 구독 플랜 엔터티 가져옴 - Plan ID: {}, Artist ID: {}, Price: {}",
                artistSubscriptionPlan.getSubscriptionPlanId(),
                artistSubscriptionPlan.getArtistId(),
                artistSubscriptionPlan.getPrice());

        // 2. 활성화된 아티스트 구독이 있는지 확인
        subscriptionRepository.findActiveSubscription(event.getSubscriberId(),
                                                      artistSubscriptionPlan.getSubscriptionPlanId().getValue())
                .ifPresentOrElse(activeSubscription ->
                                logger.info("이미 사용자(ID: {})의 활성화된 아티스트 구독(Plan ID: {})이 있습니다.",
                                        activeSubscription.getMemberId(), activeSubscription.getSubscriptionPlanId()),
                        () -> {
                            // 3. 가져온 아티스트 구독 플랜으로 구독 도메인 객체 생성
                            Subscription subscription = Subscription.builder()
                                    .subscriptionPlanId(artistSubscriptionPlan.getSubscriptionPlanId().getValue())
                                    .memberId(event.getSubscriberId())
                                    .subscribedAt(LocalDateTime.now())
                                    .expiredAt(null)
                                    .activateYn(true)
                                    .build();
                            logger.info("아티스트 구독 도메인 객체 생성 - Member ID: {}, Plan ID: {}",
                                    subscription.getMemberId(), subscription.getSubscriptionPlanId());

                            // 4. 생성한 구독 도메인 객체 저장
                            Subscription savedSubscription = subscriptionRepository.save(subscription);
                            logger.info("아티스트 구독 도메인 객체 저장 완료 - Member ID: {}, Plan ID: {}",
                                    subscription.getMemberId(), subscription.getSubscriptionPlanId());

                            // 5. 구독 사이클 시작
                            subscriptionCycleService.startFirstSubscriptionCycle(savedSubscription);
                        });
    }

    @EventListener
    @Async
    @Transactional
    public void renewSubscriptionCycle(OnChainRegularPaymentProcessedEvent event) {
        logger.info("정기 구독 결제 완료 이벤트 수신 - Subscriber Id: {}", event.getSubscriberId());

        // 1. 이벤트 정보에 따라 구독 객체 가져오기
        Integer planId = subscriptionPlanRepository.findSubscriptionPlanByPlanType(PlanType.R)
                .map(plan -> plan.getSubscriptionPlanId().getValue())
                .orElseThrow(RegularPlanNotFoundException::new);
        Subscription subscription = subscriptionRepository.findActiveSubscription(event.getSubscriberId(), planId)
                .orElseThrow();

        // 2. 해당 구독의 새로운 구독 사이클 생성
        subscriptionCycleService.startNewSubscriptionCycle(subscription);
    }

    @EventListener
    @Async
    @Transactional
    public void renewSubscriptionCycle(OnChainArtistPaymentProcessedEvent event) {
        logger.info("아티스트 구독 결제 완료 이벤트 수신 - Subscriber Id: {}, Artist Id: {}",
                event.getSubscriberId(), event.getArtistId());

        // 1. 이벤트 정보에 따라 구독 객체 가져오기
        Integer planId = subscriptionPlanRepository.findSubscriptionPlanByArtistId(event.getArtistId())
                .map(plan -> plan.getSubscriptionPlanId().getValue())
                .orElseThrow(() -> new ArtistPlanNotFoundException(event.getArtistId()));
        Subscription subscription = subscriptionRepository.findActiveSubscription(event.getSubscriberId(), planId)
                .orElseThrow();

        // 2. 해당 구독의 새로운 구독 사이클 생성
        subscriptionCycleService.startNewSubscriptionCycle(subscription);
    }
}
