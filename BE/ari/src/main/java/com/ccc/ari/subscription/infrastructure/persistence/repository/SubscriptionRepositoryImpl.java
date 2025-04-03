package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.application.repository.SubscriptionRepository;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEntity;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class SubscriptionRepositoryImpl implements SubscriptionRepository {

    private final SubscriptionJpaRepository subscriptionJpaRepository;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Override
    public void save(SubscriptionEntity subscriptionEntity) {
        subscriptionJpaRepository.save(subscriptionEntity);
    };

    @Override
    public Optional<SubscriptionEntity> findActiveSubscription(Integer memberId, Integer subscriptionPlanId) {
        List<SubscriptionEntity> subscriptions = subscriptionJpaRepository.findByMemberId(memberId)
                .stream()
                .filter(subscriptionEntity ->
                        subscriptionEntity.getSubscriptionPlanId().equals(subscriptionPlanId)
                                && subscriptionEntity.isActivateYn())
                .toList();

        if (subscriptions.isEmpty()) {
            return Optional.empty();
        }

        if (subscriptions.size() > 1) {
            logger.warn("회원 ID: {}, 구독 플랜 ID: {}에 대해 중복된 활성 구독이 발견되었습니다. 가장 최근 구독을 반환합니다.",
                    memberId, subscriptionPlanId);
            // 가장 최근에 생성된 구독을 반환
            return subscriptions.stream()
                    .max(Comparator.comparing(SubscriptionEntity::getSubscribedAt));
        }

        return Optional.of(subscriptions.get(0));
    }
}