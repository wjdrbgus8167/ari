package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.aggregation.ui.client.StreamingCountClient;
import com.ccc.ari.global.composition.response.mypage.GetMyRegularSubscriptionDetailResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.settlement.application.response.RegularSettlementDetailResponse;
import com.ccc.ari.settlement.ui.client.SettlementClient;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionCycle;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionCycleClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
public class MyRegularSubscriptionDetailService {

    private final SubscriptionPlanClient subscriptionPlanClient;
    private final MemberClient memberClient;
    private final SubscriptionClient subscriptionClient;
    private final SettlementClient settlementClient;

    public GetMyRegularSubscriptionDetailResponse getMyRegularSubscriptionDetail(Integer cycleId
            ,Integer memberId){

        log.info("memberId:{}",memberId);

        // 내 구독 목록 가져오기
        List<Subscription> subscription = subscriptionClient.getSubscriptionInfo(memberId)
                .orElseThrow(()-> new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));

        // 내 구독 목록 중에 정기 구독 가져오기
        Subscription regularSubscription = subscription.stream()
                .filter(mySubscription ->
                        subscriptionPlanClient.getSubscriptionPlan(mySubscription.getSubscriptionPlanId())
                                .getPlanType()
                                .equals(PlanType.R)
                )
                .findFirst() // 또는 필요에 따라 .findAny()
                .orElse(null); //

        // 구독 플랜 ID
        Integer subscriptionPlanId = Objects.requireNonNull(regularSubscription).getSubscriptionPlanId();
        log.info("구독 Plan ID:{}",subscriptionPlanId);

        // 구독 플랜 ID로 정기 구독권 가져오기
        SubscriptionPlan subscriptionPlan = subscriptionPlanClient.getSubscriptionPlan(subscriptionPlanId);

        // 정기 구독권 가격
        BigDecimal price = subscriptionPlan.getPrice();
        List<GetMyRegularSubscriptionDetailResponse.Settlement> settlements = new ArrayList<>();

        /*
            내 정기 구독 세부 조회 Client
         */

        RegularSettlementDetailResponse regularSettlementDetailResponse = settlementClient.getMyRegularSettlementDetail(memberId,cycleId);

        settlements = regularSettlementDetailResponse.getStreamingSettlements().stream()
                .map(streamingSettlementResult -> {

                    GetMyRegularSubscriptionDetailResponse.Settlement settlement =
                            GetMyRegularSubscriptionDetailResponse.Settlement
                                    .builder()
                                    .artistNickName(memberClient.getNicknameByMemberId(streamingSettlementResult.getArtistId()))
                                    .profileImageUrl(memberClient.getProfileImageUrlByMemberId(streamingSettlementResult.getArtistId()))
                                    .amount(streamingSettlementResult.getAmount())
                                    .streaming(streamingSettlementResult.getStreaming())
                                    .build();

                    return settlement;
                }).toList();


        return GetMyRegularSubscriptionDetailResponse.builder()
                .price(price)
                .settlements(settlements)
                .build();
    }
}
