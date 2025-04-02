package com.ccc.ari.subscription.application.service;

import com.ccc.ari.subscription.application.repository.SubscriptionPlanRepository;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.service.SubscriptionPlanManageService;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionPlanEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class SubscriptionPlanPersistenceService {

    private final SubscriptionPlanManageService subscriptionPlanManageService;
    private final SubscriptionPlanRepository subscriptionPlanRepository;

    @Transactional
    public void createRegularSubscriptionPlan(BigDecimal price) {
        SubscriptionPlan regularSubscriptionPlan =
                subscriptionPlanManageService.createRegularSubscriptionPlan(price);
        subscriptionPlanRepository.save(SubscriptionPlanEntity.from(regularSubscriptionPlan));
    }

    @Transactional
    public void createArtistSubscriptionPlan(Integer artistId, BigDecimal price) {
        SubscriptionPlan artistSubscriptionPlan = 
                subscriptionPlanManageService.createArtistSubscriptionPlan(artistId, price);
        subscriptionPlanRepository.save(SubscriptionPlanEntity.from(artistSubscriptionPlan));
    }
}
