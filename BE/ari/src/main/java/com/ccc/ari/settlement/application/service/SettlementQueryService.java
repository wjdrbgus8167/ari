package com.ccc.ari.settlement.application.service;

import com.ccc.ari.global.contract.SubscriptionContract;
import com.ccc.ari.settlement.application.command.GetMyRegularSettlementDetailCommand;
import com.ccc.ari.settlement.application.command.GetMySettlementsForDateCommand;
import com.ccc.ari.settlement.application.response.*;
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
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
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
    // LINK 단위 변환을 위한 상수 정의
    private static final BigInteger LINK_DIVISOR = BigInteger.TEN.pow(18);

    @Transactional
    public GetSettlementResponse getRegularSettlementByArtistId(GetMySettlementsForDateCommand command) {

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
                    LocalDateTime endedAt = subscriptionClient.getSubscriptionCycleById(settlementEvent.artistId.intValue())
                            .getEndedAt();
                    boolean isSameDate = endedAt.getYear() == command.getYear() &&
                            endedAt.getMonthValue() == command.getMonth() &&
                            endedAt.getDayOfMonth() == command.getDay();
                    if (isSameDate) {
                        logger.info("정기 정산 이벤트 포함. Cycle ID: {}, Wei 금액: {}, LINK 금액: {}",
                                settlementEvent.artistId,
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
                        logger.info("아티스트 정산 이벤트 포함. Cycle ID: {}, Wei 금액: {}, LINK 금액: {}",
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


        // 1. 모든 정기 구독 정산 이벤트 조회
        List<SubscriptionContract.SettlementExecutedRegularEventResponse> regularSettlements =
                settlementExecutedEventListener.getAllSettlementExecutedEventsByCycle(
                        BigInteger.valueOf(command.getCycleId()));

        logger.info("정기 정산 이벤트 수: {}", regularSettlements.size());

        // 2. StreamingSettlementResult 리스트로 변환
        List<StreamingSettlementResult> streamingResults = regularSettlements.stream()
                .map(event -> StreamingSettlementResult.builder()
                        .artistId(event.cycleId.intValue())
                        .streaming(event.streamingCount.intValue())
                        .amount(event.amount.doubleValue())
                        .build())
                .collect(Collectors.toList());

        // 3. 최종 응답 반환
        return RegularSettlementDetailResponse.builder()
                .streamingSettlements(streamingResults)
                .build();
    }


    /**
     * 아티스트 대시보드 구성을 위한 시간별 정산 내역 조회
     */
    @Transactional
    public GetArtistDailySettlementResponse getArtisthoulySettlement(Integer artistId) {

        logger.info("아티스트(ID: {})의 시간별 정산 내역 조회 시작", artistId);

        // 1. 아티스트의 정기 구독 정산 이벤트 목록 조회
        //    - 해당 아티스트와 관련된 모든 정기 구독 정산 이벤트 데이터를 가져옴
        List<SubscriptionContract.SettlementExecutedRegularEventResponse> regularSettlements =
                settlementExecutedEventListener.getAllRegularSettlementExecutedEvents(BigInteger.valueOf(artistId));

        // 2. 아티스트의 개별 정산 이벤트 목록 조회
        //    - 해당 아티스트와 관련된 모든 개별 정산 이벤트 데이터를 가져옴
        List<SubscriptionContract.SettlementExecutedArtistEventResponse> artistSettlements =
                settlementExecutedEventListener.getAllArtistSettlementExecutedEvents(BigInteger.valueOf(artistId));

        // 3. 정기 구독 정산 데이터를 시간별 합계로 그룹화
        //    - 각 구독 사이클의 종료 시간 기준으로 금액을 합산
        Map<String, Double> hourlySettlementMap = regularSettlements.stream()
                .collect(Collectors.groupingBy(
                        settlement -> subscriptionClient.getSubscriptionCycleById(settlement.artistId.intValue())
                                .getEndedAt().format(DateTimeFormatter.ofPattern("yy.MM.dd HH")),
                        Collectors.summingDouble(settlement -> new BigDecimal(settlement.amount)
                                .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP).doubleValue())
                ));

        // 4. 아티스트 구독 정산 데이터를 시간별로 합산
        //    - 기존 시간 그룹에 정산 금액을 추가하거나, 새로운 시간 그룹을 생성
        artistSettlements.forEach(settlement -> {
            String hour = subscriptionClient.getSubscriptionCycleById(settlement.cycleId.intValue())
                    .getEndedAt().format(DateTimeFormatter.ofPattern("yy.MM.dd HH"));
            double amount = new BigDecimal(settlement.amount)
                    .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP).doubleValue();
            hourlySettlementMap.merge(hour, amount, Double::sum);
        });

        // 5. 오늘과 어제의 시간 데이터를 계산하여 맵에 추가
        //    - 정산 금액이 없는 경우 기본값으로 0 설정
        LocalDateTime now = LocalDateTime.now();
        Map<String, Double> todayHourlyMap = hourlySettlementMap.entrySet().stream()
                .filter(entry -> entry.getKey().startsWith(now.toLocalDate().format(DateTimeFormatter.ofPattern("yy.MM.dd"))))
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));

        Map<String, Double> yesterdayHourlyMap = hourlySettlementMap.entrySet().stream()
                .filter(entry -> entry.getKey().startsWith(now.minusDays(1).toLocalDate().format(DateTimeFormatter.ofPattern("yy.MM.dd"))))
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));

        // 6. HourlySettlementInfo 리스트 생성
        //    - 시간과 정산 금액 데이터를 DTO 객체로 변환
        List<HourlySettlementInfo> hourlySettlementInfos = hourlySettlementMap.entrySet().stream()
                .map(entry -> HourlySettlementInfo.builder()
                        .hour(entry.getKey())
                        .settlement(entry.getValue())
                        .build())
                .collect(Collectors.toList());

        // 7. 최종적으로 로그에 내역 출력
        hourlySettlementInfos.forEach(info ->
                logger.info("아티스트(ID: {}) - 시간: {}, 정산금액: {}",
                        artistId,
                        info.getHour(),
                        String.format("%,.0f", info.getSettlement())
                )
        );
        logger.info("아티스트(ID: {}) - 총 {}건의 시간별 정산 완료",
                artistId,
                hourlySettlementInfos.size()
        );

        // 8. 최종 응답 객체 반환 (정산 내역)
        return GetArtistDailySettlementResponse.builder()
                .todaySettlement(todayHourlyMap.values().stream().mapToDouble(Double::doubleValue).sum())
                .settlementDiff(todayHourlyMap.values().stream().mapToDouble(Double::doubleValue).sum() -
                        yesterdayHourlyMap.values().stream().mapToDouble(Double::doubleValue).sum())
                .hourlySettlements(hourlySettlementInfos)
                .build();
    }

    /**
     * 나의 아티스트별 구독 이력 조회를 위한 구독 사이클별 정산 조회
     */
    public GetMyArtistSettlementResponse getMyArtistSettlement(Integer subscriberId, Integer artistId) {

        // 1. 해당 리스너의 해당 아티스트에 대한 모든 정산 이벤트 조회
        List<SubscriptionContract.SettlementExecutedRegularEventResponse> regularEventResponses =
                settlementExecutedEventListener.getSettlementExecutedRegularEventsBySubscriberIdAndArtistId(subscriberId, artistId);

        List<SubscriptionContract.SettlementExecutedArtistEventResponse> artistEventResponses =
                settlementExecutedEventListener.getSettlementExecutedArtistEventsBySubscriberIdAndArtistId(subscriberId, artistId);

        // 2. 각 정산 이벤트를 CycleSettlementInfo로 매핑 후 리스트화
        List<CycleSettlementInfo> cycleSettlements = new ArrayList<CycleSettlementInfo>(regularEventResponses.stream()
                .map(event -> CycleSettlementInfo.builder()
                        .CycleId(event.artistId.intValue())
                        .Settlement(new BigDecimal(event.amount)
                                .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP)
                                .doubleValue())
                        .build())
                .toList());

        cycleSettlements.addAll(artistEventResponses.stream()
                .map(event -> CycleSettlementInfo.builder()
                        .CycleId(event.cycleId.intValue())
                        .Settlement(new BigDecimal(event.amount)
                                .divide(new BigDecimal(LINK_DIVISOR), 18, RoundingMode.HALF_UP)
                                .doubleValue())
                        .build())
                .toList());

        // 사이클 ID 기준으로 정렬
        cycleSettlements.sort((a, b) -> b.getCycleId().compareTo(a.getCycleId()));

        // 3. Settlements 합산하여 totalSettlement 계산
        double totalSettlement = cycleSettlements.stream()
                .mapToDouble(CycleSettlementInfo::getSettlement)
                .sum();

        // 4. 로깅 추가
        logger.info("구독자({})의 아티스트({})에 대한 정산 내역 조회 완료 - 총 {}건, 총 합산 정산 금액: {}",
                subscriberId, artistId, cycleSettlements.size(), totalSettlement);

        // 5. 최종 응답 반환
        return GetMyArtistSettlementResponse.builder()
                .cycleSettlements(cycleSettlements)
                .totalSettlement(totalSettlement)
                .build();
    }
}
