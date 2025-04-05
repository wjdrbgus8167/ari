package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMySubscriptionListResponse;
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

import java.util.ArrayList;
import java.util.List;

/*
    현재 내가 구독한 구독 목록을 조회하는 Service
 */

@Service
@RequiredArgsConstructor
public class GetMySubscriptionListService {

    private final SubscriptionClient subscriptionClient;
    private final SubscriptionPlanClient subscriptionPlanClient;
    private final MemberClient memberClient;


    public GetMySubscriptionListResponse getMySubscriptionList(Integer memberId) {

        // 현재 내가 구독한 구독에 대한 정보 조회
        List<Subscription> subscriptionList = subscriptionClient.getSubscriptionInfo(memberId)
                .orElseThrow(() -> new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));

        // 각각 정기 구독과 아티스트 구독 List
        List<GetMySubscriptionListResponse.MonthlySubscriptionResponse> monthlySubscriptions = new ArrayList<>();
        List<GetMySubscriptionListResponse.ArtistSubscriptionResponse> artistSubscriptions = new ArrayList<>();

        // 가져온 구독 정보로 구분하기
        for (Subscription subscription : subscriptionList) {
            // 구독 중인 구독 플랜 정보 전체 가져오기
            SubscriptionPlan plan = subscriptionPlanClient.getSubscriptionPlan(subscription.getSubscriptionPlanId());

            // 만약 정기 구독이면
            if (plan.getPlanType() == PlanType.R) {
                monthlySubscriptions.add(
                        GetMySubscriptionListResponse.MonthlySubscriptionResponse.builder()
                                .price(plan.getPrice())
                                .subscribeAt(subscription.getSubscribedAt())
                                .expiredAt(subscription.getExpiredAt())
                                .build()
                );
            } else {
                // 아티스트 구독이라면
                String artistName = memberClient.getNicknameByMemberId(plan.getArtistId());
                artistSubscriptions.add(
                        GetMySubscriptionListResponse.ArtistSubscriptionResponse.builder()
                                .artistName(artistName)
                                .price(plan.getPrice())
                                .subscribeAt(subscription.getSubscribedAt())
                                .expiredAt(subscription.getExpiredAt())
                                .build()
                );
            }
        }

        return GetMySubscriptionListResponse.builder()
                .monthly(monthlySubscriptions)
                .artist(artistSubscriptions)
                .build();
    }

}
