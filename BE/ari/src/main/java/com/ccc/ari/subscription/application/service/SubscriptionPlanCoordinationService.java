package com.ccc.ari.subscription.application.service;

import com.ccc.ari.subscription.application.repository.SubscriptionPlanRepository;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionPlanEntity;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class SubscriptionPlanCoordinationService {

    private final SubscriptionPlanPersistenceService subscriptionPlanPersistenceService;
    private final SubscriptionPlanRepository subscriptionPlanRepository;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Transactional
    public SubscriptionPlanEntity getOrCreateRegularPlan(BigDecimal price) {
        logger.info("정기 구독 플랜 조회 또는 생성 시작 (price: {})", price);
        return subscriptionPlanRepository.findSubscriptionPlanByPlanType(PlanType.R)
                .orElseGet(() -> {
                    logger.info("정기 구독 플랜이 존재하지 않아 새로 생성합니다. (price: {})", price);
                    subscriptionPlanPersistenceService.createRegularSubscriptionPlan(price);
                    return subscriptionPlanRepository.findSubscriptionPlanByPlanType(PlanType.R)
                            .orElseThrow(() -> {
                                logger.error("정기 구독 플랜 생성 실패 (price: {})", price);
                                return new RuntimeException("정기 구독 플랜 생성 실패");
                            });
                });
    }

    @Transactional
    public SubscriptionPlanEntity getOrCreateArtistPlan(Integer artistId, BigDecimal price) {
        logger.info("아티스트 구독 플랜 조회 또는 생성 시작 (artistId: {}, price: {})", artistId, price);
        return subscriptionPlanRepository.findSubscriptionPlanByArtistId(artistId)
                .orElseGet(() -> {
                    logger.info("아티스트 구독 플랜이 존재하지 않아 새로 생성합니다. (artistId: {}, price: {})", artistId, price);
                    subscriptionPlanPersistenceService.createArtistSubscriptionPlan(artistId, price);
                    return subscriptionPlanRepository.findSubscriptionPlanByArtistId(artistId)
                            .orElseThrow(() -> {
                                logger.error("아티스트 구독 플랜 생성 실패 (artistId: {}, price: {})", artistId, price);
                                return new RuntimeException("아티스트 구독 플랜 생성 실패");
                            });
                });
    }
}
