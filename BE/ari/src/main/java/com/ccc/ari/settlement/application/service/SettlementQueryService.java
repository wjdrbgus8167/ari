package com.ccc.ari.settlement.application.service;

import com.ccc.ari.global.contract.SubscriptionContract;
import com.ccc.ari.settlement.application.command.GetMyRegularSettlementDetailCommand;
import com.ccc.ari.settlement.application.command.GetMySettlementsForDateCommand;
import com.ccc.ari.settlement.application.response.GetSettlementResponse;
import com.ccc.ari.settlement.application.response.RegularSettlementDetailResponse;
import com.ccc.ari.settlement.application.response.StreamingSettlementResult;
import com.ccc.ari.settlement.infrastructure.blockchain.adapter.SettlementExecutedEventListener;
import com.ccc.ari.subscription.ui.client.SubscriptionClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SettlementQueryService {

    private final SettlementExecutedEventListener settlementExecutedEventListener;
    private final SubscriptionClient subscriptionClient;
    
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    private static final DecimalFormat LINK_FORMAT = new DecimalFormat("0.##################"); // 18자리 소수점

    @Transactional
    public GetSettlementResponse getRegularSettlementByArtistId(GetMySettlementsForDateCommand command) {

        // LINK 단위 변환을 위한 상수 정의
        final BigInteger LINK_DIVISOR = BigInteger.TEN.pow(18);

        BigDecimal regularSettlement = BigDecimal.ZERO;
        BigDecimal artistSettlement = BigDecimal.ZERO;

        logger.info("정산 조회 시작. 아티스트 ID: {}, 날짜: {}-{}-{}",
                command.getArtistId(), command.getYear(), command.getMonth(), command.getDay());

        // 1. 해당 아티스트의 모든 정기, 아티스트 구독 사이클의 정산 목록 가져오기
        List<SubscriptionContract.SettlementExecutedRegularEventResponse> regularSettlements =
                settlementExecutedEventListener.getAllRegularSettlementExecutedEvents(BigInteger.valueOf(command.getArtistId()));

        List<SubscriptionContract.SettlementExecutedArtistEventResponse> artistSettlements =
                settlementExecutedEventListener.getAllArtistSettlementExecutedEvents(BigInteger.valueOf(command.getArtistId()));

        logger.info("정기 정산 이벤트 수: {}, 아티스트 정산 이벤트 수: {}", regularSettlements.size(), artistSettlements.size());

        // 2. 정산 목록 중 해당 날짜에 이뤄진 정산만 합산(시이클 종료 시간 기준)
        regularSettlement = regularSettlements.stream()
                .filter(settlementEvent -> {
                    LocalDateTime endedAt = subscriptionClient.getSubscriptionCycleById(settlementEvent.cycleId.intValue())
                            .getEndedAt();
                    boolean isSameDate = endedAt.getYear() == command.getYear() &&
                            endedAt.getMonthValue() == command.getMonth() &&
                            endedAt.getDayOfMonth() == command.getDay();
                    if (isSameDate) {
                        logger.info("정기 정산 이벤트 포함. Cycle ID: {}, Wei 금액: {}, LINK 금액: {}",
                                settlementEvent.cycleId,
                                settlementEvent.amount,
                                new BigDecimal(settlementEvent.amount)
                                        .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP));
                    }
                    return isSameDate;
                })
                .map(settlementEvent -> new BigDecimal(settlementEvent.amount)
                        .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        artistSettlement = artistSettlements.stream()
                .filter(settlementEvent -> {
                    LocalDateTime endedAt =
                            subscriptionClient.getSubscriptionCycleById(settlementEvent.cycleId.intValue()).getEndedAt();
                    boolean isSameDate = endedAt.getYear() == command.getYear() &&
                            endedAt.getMonthValue() == command.getMonth() &&
                            endedAt.getDayOfMonth() == command.getDay();
                    if (isSameDate) {
                        logger.info("정기 정산 이벤트 포함. Cycle ID: {}, Wei 금액: {}, LINK 금액: {}",
                                settlementEvent.cycleId,
                                settlementEvent.amount,
                                new BigDecimal(settlementEvent.amount)
                                        .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP));
                    }
                    return isSameDate;
                })
                .map(settlementEvent -> new BigDecimal(settlementEvent.amount)
                        .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        logger.info("정산 완료. 아티스트 ID: {}, 정기 정산 합계: {} LINK, 아티스트 정산 합계: {} LINK",
                command.getArtistId(), regularSettlement, artistSettlement);

        return GetSettlementResponse.builder()
                .regularSettlement(String.format("%.18f", regularSettlement))
                .artistSettlement(String.format("%.18f", artistSettlement))
                .build();
    }

    @Transactional
    public RegularSettlementDetailResponse getMyRegularSettlementDetail(GetMyRegularSettlementDetailCommand command) {
        logger.info("정기 구독 정산 상세 내역 조회 시작. 구독자 ID: {}, 사이클 ID: {}",
                command.getSubscriberId(), command.getCycleId());

        try {
            // 1. 모든 정기 구독 정산 이벤트 조회
            List<SubscriptionContract.SettlementExecutedRegularEventResponse> regularSettlements =
                    settlementExecutedEventListener.getAllSettlementExecutedEventsByCycle(
                            BigInteger.valueOf(command.getCycleId()));

            logger.info("정기 정산 이벤트 수: {}", regularSettlements.size());

            // 2. StreamingSettlementResult 리스트로 변환
            List<StreamingSettlementResult> streamingResults = regularSettlements.stream()
                    .map(event -> StreamingSettlementResult.builder()
                            .artistId(event.artistId.intValue())
                            .streaming(event.streamingCount.intValue())
                            .amount(event.amount.doubleValue())
                            .build())
                    .collect(Collectors.toList());

            // 3. 최종 응답 반환
            return RegularSettlementDetailResponse.builder()
                    .streamingSettlements(streamingResults)
                    .build();

        } catch (Exception e) {
            logger.error("정산 상세 내역 조회 중 오류 발생", e);
            return RegularSettlementDetailResponse.builder()
                    .streamingSettlements(List.of())
                    .build();
        }
    }
}
