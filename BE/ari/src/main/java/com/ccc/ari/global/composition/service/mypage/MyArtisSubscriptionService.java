package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.aggregation.ui.client.StreamingCountClient;
import com.ccc.ari.aggregation.ui.response.GetArtistTrackCountListResponse;
import com.ccc.ari.aggregation.ui.response.TrackCountResult;
import com.ccc.ari.global.composition.response.mypage.GetMyArtistSubscriptionDetailResponse;
import com.ccc.ari.global.composition.response.mypage.GetMyArtistSubscriptionResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.type.PlanType;
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
    private final SubscriptionCycleClient subscriptionCycleClient;
    private final StreamingCountClient streamingCountClient;

    // 나의 아티스트 구독 목록 조회
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

    // 내 아티스트 구독 상세 조회

    public GetMyArtistSubscriptionDetailResponse getMyArtistSubscriptionDetail(Integer memberId,Integer artistId){

        // 내 구독 목록 조회
        List<Subscription> mySubscriptionIdList = subscriptionClient.getSubscriptionInfo(memberId)
                .orElseThrow(()-> new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));

        GetArtistTrackCountListResponse trackCountListResponse = streamingCountClient.getArtistTrackCounts(artistId);

        // 전체 스트리밍 횟수 계산
        int totalStreamingCount = trackCountListResponse.getTrackCountList().stream()
                .mapToInt(TrackCountResult::getTotalCount)
                .sum();

        // 내 아티스트 구독 플랜 조회
        List<GetMyArtistSubscriptionDetailResponse.ArtistSubscriptionDetail> artistSubscriptions =
                mySubscriptionIdList.stream()
                        .filter(subscription -> {
                            SubscriptionPlan plan =
                                    subscriptionPlanClient.getSubscriptionPlan(subscription.getSubscriptionPlanId());
                            return artistId.equals(plan.getArtistId());
                        })
                        .flatMap(subscription -> {

                            SubscriptionPlan plan =
                                    subscriptionPlanClient.getSubscriptionPlan(subscription.getSubscriptionPlanId());
                            List<SubscriptionCycle> cycles = subscriptionCycleClient.getSubscriptionCycle(subscription.getSubscriptionId());

                            return cycles.stream()
                                    .map(cycle -> GetMyArtistSubscriptionDetailResponse.ArtistSubscriptionDetail.builder()
                                            .planType(plan.getPlanType().name())
                                            .startedAt(cycle.getStartedAt())
                                            .endedAt(cycle.getEndedAt())
                                            .settlement(BigDecimal.valueOf(11.11)) // plan에 금액 필드 있다고 가정
                                            .build());
                        })
                        .toList();





        return GetMyArtistSubscriptionDetailResponse.builder()
                .artistNickName(memberClient.getNicknameByMemberId(artistId))
                .profileImageUrl(memberClient.getProfileImageUrlByMemberId(artistId))
                .totalStreamingCount(totalStreamingCount)
                .totalSettlement(BigDecimal.valueOf(11.11))
                .subscriptions(artistSubscriptions)
                .build();
    }

}
