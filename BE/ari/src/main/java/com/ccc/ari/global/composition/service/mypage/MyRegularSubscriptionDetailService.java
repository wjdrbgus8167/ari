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

        if(subscription.size() != 0&&!subscription.isEmpty()){

            for(Subscription sub : subscription){
                log.info("현재 내 구독 목록 ID:{}",sub.getSubscriptionId().getValue());

            }

        }
        // 내 구독 목록 중에 정기 구독 가져오기
        Subscription regularSubscription = subscription.stream()
                .filter(mySubscription ->
                        subscriptionPlanClient.getSubscriptionPlan(mySubscription.getSubscriptionPlanId())
                                .getPlanType()
                                .equals(PlanType.R)
                )
                .findFirst() // 또는 필요에 따라 .findAny()
                .orElseThrow(()-> new ApiException(ErrorCode.SUBSCRIPTION_REGULAR_NOT_FOUND));

        log.info("현재 나의 정기 구독 ID(subscriptionId):{}",regularSubscription.getSubscriptionId().getValue());

        // 구독 플랜 ID
        Integer subscriptionPlanId = Objects.requireNonNull(regularSubscription).getSubscriptionPlanId();
        log.info("구독 Plan ID:{}",subscriptionPlanId);

        // 구독 목록조회-> 정기구독만 빼내기-> 정기구독의 subscriptionPlan으로 plan 조회(정기구독권 가격을 위해서)

        // 구독 플랜 ID로 정기 구독권 가져오기
        SubscriptionPlan subscriptionPlan = subscriptionPlanClient.getSubscriptionPlan(subscriptionPlanId);

        // 정기 구독권 가격
        BigDecimal price = subscriptionPlan.getPrice();
        List<GetMyRegularSubscriptionDetailResponse.Settlement> settlements = new ArrayList<>();

        /*
            내 정기 구독 세부 조회 Client
         */
        log.info("내 정기 구독 세부 조회 시작");
        // 현재 여기서 정기구독에 따른 세부 개역을 못가져오고 있음
        RegularSettlementDetailResponse regularSettlementDetailResponse = settlementClient.getMyRegularSettlementDetail(memberId,cycleId);
        log.info("내 정기 구독 세부 조회 :{}",regularSettlementDetailResponse.getStreamingSettlements().size());

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

        log.info("정기 구독 사이클 확인 :{}",settlements.size());
        return GetMyRegularSubscriptionDetailResponse.builder()
                .price(price)
                .settlements(settlements)
                .build();
    }
}
