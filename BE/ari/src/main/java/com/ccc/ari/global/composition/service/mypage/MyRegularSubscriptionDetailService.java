package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyRegularSubscriptionDetailResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.settlement.application.response.RegularSettlementDetailResponse;
import com.ccc.ari.settlement.ui.client.SettlementClient;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionCompositionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MyRegularSubscriptionDetailService {

    private final SubscriptionPlanClient subscriptionPlanClient;
    private final MemberClient memberClient;
    private final SubscriptionCompositionClient subscriptionCompositionClient;
    private final SettlementClient settlementClient;

    public GetMyRegularSubscriptionDetailResponse getMyRegularSubscriptionDetail(Integer cycleId
            ,Integer memberId){

        log.info("memberId:{}",memberId);

        // 내 구독 목록 가져오기
        List<Subscription> subscription = subscriptionCompositionClient.getSubscriptionInfo(memberId)
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
        List<GetMyRegularSubscriptionDetailResponse.Settlement> settlements;

        /*
            내 정기 구독 세부 조회 Client
         */
        log.info("내 정기 구독 세부 조회 시작");
        // 현재 여기서 정기구독에 따른 세부 개역을 못가져오고 있음
        RegularSettlementDetailResponse regularSettlementDetailResponse = settlementClient.getMyRegularSettlementDetail(memberId,cycleId);
        log.info("내 정기 구독 세부 조회 :{}",regularSettlementDetailResponse.getStreamingSettlements().size());
        DecimalFormat df = new DecimalFormat("0.00");
        settlements = regularSettlementDetailResponse.getStreamingSettlements().stream()
                        .map(streamingSettlementResult -> {
                            log.info("정산 : {}", streamingSettlementResult.getAmount());
                            log.info("스티리밍 : {}", streamingSettlementResult.getStreaming());

                            // 1. Double을 BigDecimal로 변환
                            BigDecimal bigDecimalAmount = new BigDecimal(String.valueOf(streamingSettlementResult.getAmount()));

                            BigDecimal divisor = new BigDecimal("1000000000000000000"); // 10^16
                            BigDecimal result = bigDecimalAmount.divide(divisor);
                            BigDecimal roundedAmount = result .setScale(2, RoundingMode.HALF_UP);

                            return GetMyRegularSubscriptionDetailResponse.Settlement.builder()
                                    .artistNickName(memberClient.getNicknameByMemberId(streamingSettlementResult.getArtistId()))
                                    .profileImageUrl(memberClient.getProfileImageUrlByMemberId(streamingSettlementResult.getArtistId()))
                                    .amount(roundedAmount.doubleValue())
                                    .streaming(streamingSettlementResult.getStreaming())
                                    .build();
                        })
                        .collect(Collectors.toList());

        log.info("정기 구독 사이클 확인 :{}",settlements.size());

        return GetMyRegularSubscriptionDetailResponse.builder()
                .price(price)
                .settlements(settlements)
                .build();
    }
}
