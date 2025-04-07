package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.aggregation.ui.client.StreamingCountClient;
import com.ccc.ari.global.composition.response.mypage.GetMyRegularSubscriptionDetailResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionCycleClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MyRegularSubscriptionDetailService {

    private final SubscriptionPlanClient subscriptionPlanClient;
    private final MemberClient memberClient;
    private final StreamingCountClient streamingCountClient;
    private final SubscriptionCycleClient subscriptionCycleClient;
    private final SubscriptionClient subscriptionClient;

    public GetMyRegularSubscriptionDetailResponse getMyRegularSubscriptionDetail(Integer subscriptionId
            ,Integer memberId){

        Subscription subscription = subscriptionClient.getSubscription(subscriptionId)
                .orElseThrow(() -> new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));

        SubscriptionPlan subscriptionPlan = subscriptionPlanClient.getSubscriptionPlan(subscriptionId);

        BigDecimal price = subscriptionPlan.getPrice();
        List<GetMyRegularSubscriptionDetailResponse.Settlement> settlements = new ArrayList<>();

        SubscriptionCycle subscriptionCycle = subscriptionCycleClient.getLatestSubscriptionCycle(subscription.getSubscriptionId());
        /*
            내 정기 구독 세부 조회 Client
         */




        return GetMyRegularSubscriptionDetailResponse.builder()
                .price(price)
                .build();
    }
}
