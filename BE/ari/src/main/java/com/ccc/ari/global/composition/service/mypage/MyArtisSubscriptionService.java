package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyArtistSubscriptionResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/*
    내 아티스트 구독 목록 조회 Service
 */
@Service
@RequiredArgsConstructor
public class MyArtisSubscriptionService {

    private final SubscriptionPlanClient subscriptionPlanClient;
    private final SubscriptionClient subscriptionClient;
    private final MemberClient memberClient;

    public GetMyArtistSubscriptionResponse getMyArtistSubscription(Integer memberId){

        // 내 구독 목록 조회
        List<Subscription> mySubscriptionIdList = subscriptionClient.getSubscriptionInfo(memberId)
                .orElseThrow(()-> new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));

        // 내 아티스트 구독 플랜 조회
        List<GetMyArtistSubscriptionResponse.MyArtisSubscription> artistSubscriptions = mySubscriptionIdList.stream()
                .filter(subscription -> {

                    // 정기 구독은 필터링
                    SubscriptionPlan plan =
                            subscriptionPlanClient.getSubscriptionPlan(subscription.getSubscriptionPlanId());
                    return !PlanType.R.equals(plan.getPlanType()); // PlanType.R이 아닌 것만 필터링
                })
                .map(subscription -> {

                    SubscriptionPlan subscriptionPlan = subscriptionPlanClient
                            .getSubscriptionPlan(subscription.getSubscriptionPlanId());

                    Integer artistId = subscriptionPlan.getArtistId();

                    return GetMyArtistSubscriptionResponse.MyArtisSubscription.builder()
                            .artistId(artistId)
                            .artistNickName(memberClient.getNicknameByMemberId(artistId))

                            .build();
                })
                .toList();

        return GetMyArtistSubscriptionResponse.builder()
                .artists(artistSubscriptions)
                .build();
    }

}
