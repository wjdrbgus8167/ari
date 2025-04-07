package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.repository.SubscriptionRepository;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEntity;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
@RequiredArgsConstructor
public class SubscriptionRepositoryImpl implements SubscriptionRepository {

    private final SubscriptionJpaRepository subscriptionJpaRepository;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Override
    public Subscription save(Subscription subscription) {
        return subscriptionJpaRepository.save(SubscriptionEntity.fromNew(subscription)).toModel();
    };

    @Override
    public Optional<Subscription> findActiveSubscription(Integer memberId, Integer subscriptionPlanId) {
        List<SubscriptionEntity> subscriptionEntities = subscriptionJpaRepository.findByMemberId(memberId)
                .stream()
                .filter(subscriptionEntity ->
                        subscriptionEntity.getSubscriptionPlanId().equals(subscriptionPlanId)
                                && subscriptionEntity.isActivateYn())
                .toList();

        if (subscriptionEntities.isEmpty()) {
            return Optional.empty();
        }

        if (subscriptionEntities.size() > 1) {
            logger.warn("회원 ID: {}, 구독 플랜 ID: {}에 대해 중복된 활성 구독이 발견되었습니다. 가장 최근 구독을 반환합니다.",
                    memberId, subscriptionPlanId);
            // 가장 최근에 생성된 구독을 반환
            return subscriptionEntities.stream()
                    .max(Comparator.comparing(SubscriptionEntity::getSubscribedAt))
                    .map(SubscriptionEntity::toModel);
        }

        return Optional.of(subscriptionEntities.get(0).toModel());
    }

    @Override
    public Optional<Subscription> findBySubscriptionId(Integer subscriptionId) {
        return subscriptionJpaRepository.findById(subscriptionId).isPresent() ?
                Optional.of(subscriptionJpaRepository.findById(subscriptionId).get().toModel()) :
                Optional.empty();
    }

    public Optional<List<Subscription>> findListByMemberId(Integer memberId) {
        List<SubscriptionEntity> list = subscriptionJpaRepository.findAllByMemberId(memberId);

        if (list.isEmpty()) {
            return Optional.empty(); // 여기서 Optional.empty()를 주면 클라이언트에서 orElseThrow로 예외 발생 가능
        }

        List<Subscription> subscriptions = list.stream()
                .map(SubscriptionEntity::toModel)
                .collect(Collectors.toList());

        return Optional.of(subscriptions);
    }

    @Override
    public Optional<List<Subscription>> findListByMemberIdAndSubscriptionPlanId(Integer memberId, Integer subscriptionPlanId) {
        return subscriptionJpaRepository.findByMemberIdAndSubscriptionPlanId(memberId, subscriptionPlanId)
                .map(subscriptionEntities -> subscriptionEntities.stream()
                        .map(SubscriptionEntity::toModel)
                        .toList());
    }

    @Override
    public List<Subscription> findAllBySubscriptionPlanIdAndActivateYnTrue(Integer subscriptionPlanId) {
        return subscriptionJpaRepository.findAllBySubscriptionPlanIdAndActivateYnTrue(subscriptionPlanId).stream()
                .map(SubscriptionEntity::toModel)
                .toList();
    }

    @Override
    public List<Subscription> findAllBySubscriptionPlanIdAndSubscribedAtBetweenAndActivateYnTrue(Integer subscriptionId, LocalDateTime start, LocalDateTime end) {
        return subscriptionJpaRepository.findAllBySubscriptionPlanIdAndSubscribedAtBetweenAndActivateYnTrue(subscriptionId,start,end).stream()
                .map(SubscriptionEntity::toModel)
                .toList();
    }

    @Override
    public Optional<Subscription> findSubscription(Integer subscriptionId) {
        return subscriptionJpaRepository.findById(subscriptionId).map(SubscriptionEntity::toModel);
    }

}