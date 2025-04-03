package com.ccc.ari.subscription.application.service;

import com.ccc.ari.subscription.application.repository.SubscriptionRepository;
import com.ccc.ari.subscription.event.ArtistSubscriptionOnChainCreatedEvent;
import com.ccc.ari.subscription.event.RegularSubscriptionOnChainCreatedEvent;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEntity;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionPlanEntity;
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
public class SubscriptionOffChainCreateService {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanCoordinationService subscriptionPlanCoordinationService;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @EventListener
    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createOffChainRegularSubscription(RegularSubscriptionOnChainCreatedEvent event) {
        logger.info("오프체인 정기 구독 생성 이벤트 리스너 실행 시작 - 스레드: {}", Thread.currentThread().getName());
        logger.info("정기 구독 생성 이벤트 수신 - Subscriber ID: {}, Amount: {}", event.getSubscriberId(), event.getAmount());

        // 1. 정기 구독 플랜 엔터티 가져오기
        SubscriptionPlanEntity regularSubscriptionPlanEntity =
                subscriptionPlanCoordinationService.getOrCreateRegularPlan(event.getAmount());
        logger.info("정기 구독 플랜 엔터티 가져옴 - Plan ID: {}, Price: {}",
                regularSubscriptionPlanEntity.getSubscriptionPlanId(), regularSubscriptionPlanEntity.getPrice());

        // 2. 활성화 된 구독이 있는지 확인
        subscriptionRepository.findActiveSubscription(event.getSubscriberId(), regularSubscriptionPlanEntity.getSubscriptionPlanId())
                .ifPresentOrElse(activeSubscriptionEntity ->
                                logger.info("이미 사용자(ID: {})의 활성화된 정기 구독이 있습니다.", activeSubscriptionEntity.getMemberId()),
                        () -> {
                            // 3. 가져온 정기 구독 플랜으로 구독 엔터티 생성
                            SubscriptionEntity subscriptionEntity = SubscriptionEntity.builder()
                                    .subscriptionPlanId(regularSubscriptionPlanEntity.getSubscriptionPlanId())
                                    .memberId(event.getSubscriberId())
                                    .subscribedAt(LocalDateTime.now())
                                    .expiredAt(null)
                                    .activateYn(true)
                                    .build();
                            logger.info("정기 구독 엔터티 생성 - Member ID: {}, Plan ID: {}",
                                    subscriptionEntity.getMemberId(), subscriptionEntity.getSubscriptionPlanId());

                            // 4. 생성한 구독 엔터티 저장
                            subscriptionRepository.save(subscriptionEntity);
                            logger.info("정기 구독 엔터티 저장 완료 - Member ID: {}, Plan ID: {}",
                                    subscriptionEntity.getMemberId(), subscriptionEntity.getSubscriptionPlanId());
                        });
    }

    @EventListener
    @Async
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createOffChainArtistSubscription(ArtistSubscriptionOnChainCreatedEvent event) {
        logger.info("아티스트 구독 생성 이벤트 수신 - Subscriber ID: {}, Artist ID: {}, Amount: {}",
                event.getSubscriberId(), event.getArtistId(), event.getAmount());

        // 1. 아티스트 구독 플랜 엔터티 가져오기
        SubscriptionPlanEntity artistSubscriptionPlanEntity =
                subscriptionPlanCoordinationService.getOrCreateArtistPlan(event.getArtistId(), event.getAmount());
        logger.info("아티스트 구독 플랜 엔터티 가져옴 - Plan ID: {}, Artist ID: {}, Price: {}",
                artistSubscriptionPlanEntity.getSubscriptionPlanId(), 
                artistSubscriptionPlanEntity.getArtistId(), 
                artistSubscriptionPlanEntity.getPrice());

        // 2. 활성화된 아티스트 구독이 있는지 확인
        subscriptionRepository.findActiveSubscription(event.getSubscriberId(), artistSubscriptionPlanEntity.getSubscriptionPlanId())
                .ifPresentOrElse(activeSubscriptionEntity ->
                                logger.info("이미 사용자(ID: {})의 활성화된 아티스트 구독(Plan ID: {})이 있습니다.",
                                        activeSubscriptionEntity.getMemberId(), activeSubscriptionEntity.getSubscriptionPlanId()),
                        () -> {
                            // 3. 가져온 아티스트 구독 플랜으로 구독 엔터티 생성
                            SubscriptionEntity subscriptionEntity = SubscriptionEntity.builder()
                                    .subscriptionPlanId(artistSubscriptionPlanEntity.getSubscriptionPlanId())
                                    .memberId(event.getSubscriberId())
                                    .subscribedAt(LocalDateTime.now())
                                    .expiredAt(null)
                                    .activateYn(true)
                                    .build();
                            logger.info("아티스트 구독 엔터티 생성 - Member ID: {}, Plan ID: {}",
                                    subscriptionEntity.getMemberId(), subscriptionEntity.getSubscriptionPlanId());

                            // 4. 생성한 구독 엔터티 저장
                            subscriptionRepository.save(subscriptionEntity);
                            logger.info("아티스트 구독 엔터티 저장 완료 - Member ID: {}, Plan ID: {}",
                                    subscriptionEntity.getMemberId(), subscriptionEntity.getSubscriptionPlanId());
                        });
    }
}
