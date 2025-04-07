package com.ccc.ari.settlement.application.service;

import com.ccc.ari.global.contract.SubscriptionContract;
import com.ccc.ari.settlement.application.command.GetMySettlementsForDateCommand;
import com.ccc.ari.settlement.application.response.GetSettlementResponse;
import com.ccc.ari.settlement.infrastructure.blockchain.adapter.SettlementExecutedEventListener;
import com.ccc.ari.subscription.ui.client.SubscriptionClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SettlementQueryService {

    private final SettlementExecutedEventListener settlementExecutedEventListener;
    private final SubscriptionClient subscriptionClient;
    
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Transactional
    public GetSettlementResponse getRegularSettlementByArtistId(GetMySettlementsForDateCommand command) {

        int regularSettlement = 0;
        int artistSettlement = 0;

        logger.info("정산 조회 시작. 아티스트 ID: {}, 날짜: {}-{}-{}",
                command.getArtistId(), command.getYear(), command.getMonth(), command.getDay());

        // 1. 해당 아티스트의 모든 정기, 아티스트 구독 사이클의 정산 목록 가져오기
        List<SubscriptionContract.SettlementExecutedRegularEventResponse> regularSettlements =
                settlementExecutedEventListener.getAllRegularSettlementExecutedEvents(BigInteger.valueOf(command.getArtistId()));

        List<SubscriptionContract.SettlementExecutedArtistEventResponse> artistSettlements =
                settlementExecutedEventListener.getAllArtistSettlementExecutedEvents(BigInteger.valueOf(command.getArtistId()));

        logger.info("정기 정산 이벤트 수: {}, 아티스트 정산 이벤트 수: {}", regularSettlements.size(), artistSettlements.size());

        // 2. 정산 목록 중 해당 날짜에 이뤄진 정산만 합산(시이클 종료 시간 기준)
        regularSettlement += regularSettlements.stream()
                .filter(settlementEvent -> {
                    LocalDateTime endedAt = subscriptionClient.getSubscriptionCycleById(settlementEvent.cycleId.intValue())
                            .getEndedAt();
                    boolean isSameDate = endedAt.getYear() == command.getYear() &&
                            endedAt.getMonthValue() == command.getMonth() &&
                            endedAt.getDayOfMonth() == command.getDay();
                    if (isSameDate) {
                        logger.info("정기 정산 이벤트 포함. Cycle ID: {}, 금액: {}",
                                settlementEvent.cycleId, settlementEvent.amount);
                    }
                    return isSameDate;
                })
                .mapToInt(settlementEvent -> settlementEvent.amount.intValue())
                .sum();
        artistSettlement += artistSettlements.stream()
                .filter(settlementEvent -> {
                    LocalDateTime endedAt =
                            subscriptionClient.getSubscriptionCycleById(settlementEvent.cycleId.intValue()).getEndedAt();
                    boolean isSameDate = endedAt.getYear() == command.getYear() &&
                            endedAt.getMonthValue() == command.getMonth() &&
                            endedAt.getDayOfMonth() == command.getDay();
                    if (isSameDate) {
                        logger.info("아티스트 정산 이벤트 포함. Cycle ID: {}, 금액: {}",
                                settlementEvent.cycleId, settlementEvent.amount);
                    }
                    return isSameDate;
                })
                .mapToInt(settlementEvent -> settlementEvent.amount.intValue())
                .sum();

        logger.info("정산 완료. 아티스트 ID: {}, 정기 정산 합계: {}, 아티스트 정산 합계: {}",
                command.getArtistId(), regularSettlement, artistSettlement);

        return GetSettlementResponse.builder()
                .regularSettlement(regularSettlement)
                .artistSettlement(artistSettlement)
                .build();
    }
}
