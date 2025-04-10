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
import com.ccc.ari.settlement.application.response.CycleSettlementInfo;
import com.ccc.ari.settlement.application.response.GetMyArtistSettlementResponse;
import com.ccc.ari.settlement.ui.client.SettlementClient;
import com.ccc.ari.subscription.application.response.CycleInfo;
import com.ccc.ari.subscription.application.response.GetMyArtistCyclesResponse;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionCompositionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import com.ccc.ari.subscription.ui.client.SubscriptionClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/*
    내 아티스트 구독 목록 조회 Service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MyArtisSubscriptionService {

    private final SubscriptionPlanClient subscriptionPlanClient;
    private final SubscriptionCompositionClient subscriptionCompositionClient;
    private final SubscriptionClient subscriptionClient;
    private final MemberClient memberClient;
    private final StreamingCountClient streamingCountClient;
    private final SettlementClient settlementClient;

    // 나의 아티스트 구독 목록 조회
    public GetMyArtistSubscriptionResponse getMyArtistSubscription(Integer memberId){

        // 내 구독 목록 조회
        List<Subscription> mySubscriptionIdList = subscriptionCompositionClient.getSubscriptionInfo(memberId)
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
        List<Subscription> mySubscriptionIdList = subscriptionCompositionClient.getSubscriptionInfo(memberId)
                .orElseThrow(()-> new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));

        GetArtistTrackCountListResponse trackCountListResponse = streamingCountClient.getArtistTrackCounts(artistId);

        // 전체 스트리밍 횟수 계산
        int totalStreamingCount = trackCountListResponse.getTrackCountList().stream()
                .mapToInt(TrackCountResult::getTotalCount)
                .sum();

        log.info("아티스트 구독 사이클 조회 시작");
        log.info("아티스트 구독 사이클 정산 시작");

        GetMyArtistCyclesResponse getMyArtistCyclesResponse = subscriptionClient.getMyArtistCyclesResponse(memberId,artistId);

        GetMyArtistSettlementResponse getMyArtistSettlementResponse = settlementClient.getMyArtistSettlement(memberId,artistId);

        List<GetMyArtistSubscriptionDetailResponse.ArtistSubscriptionDetail> artistSubscriptions = new ArrayList<>();

        log.info("아티스트 구독 응답 리스트 만들기 시작");
        log.info("사이클 개수: {}", getMyArtistCyclesResponse.getCycleInfos().size());
        log.info("정산 개수: {}", getMyArtistSettlementResponse.getCycleSettlements().size());

        if (!getMyArtistCyclesResponse.getCycleInfos().isEmpty() && !getMyArtistSettlementResponse.getCycleSettlements().isEmpty()) {

            // cycleId 기준으로 정산 정보 Map으로 변환
            Map<Integer, CycleSettlementInfo> settlementMap = getMyArtistSettlementResponse.getCycleSettlements().stream()
                    .collect(Collectors.toMap(
                            CycleSettlementInfo::getCycleId,
                            s -> s,
                            (existing, replacement) -> replacement  // 뒤에 값으로 덮어쓰기
                    ));

            for (CycleInfo cycleInfo : getMyArtistCyclesResponse.getCycleInfos()) {
                CycleSettlementInfo matchedSettlement = settlementMap.get(cycleInfo.getCycleId());

                if (matchedSettlement != null) {
                    log.info("사이클 ID: {}", cycleInfo.getCycleId());

                    artistSubscriptions.add(GetMyArtistSubscriptionDetailResponse.ArtistSubscriptionDetail.builder()
                            .planType(cycleInfo.getPlanType().toString())
                            .startedAt(cycleInfo.getStartedAt())
                            .endedAt(cycleInfo.getEndedAt())
                            .settlement(matchedSettlement.getSettlement())
                            .build());
                } else {
                    log.info("정산 정보 없음. Cycle ID: {}", cycleInfo.getCycleId());
                }
            }
        }


        return GetMyArtistSubscriptionDetailResponse.builder()
                .artistNickName(memberClient.getNicknameByMemberId(artistId))
                .profileImageUrl(memberClient.getProfileImageUrlByMemberId(artistId))
                .totalStreamingCount(totalStreamingCount)
                .totalSettlement(getMyArtistSettlementResponse.getTotalSettlement())
                .subscriptions(artistSubscriptions)
                .build();
    }

}
