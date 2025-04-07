package com.ccc.ari.settlement.application.service;

import com.ccc.ari.aggregation.ui.client.StreamingCountClient;
import com.ccc.ari.aggregation.ui.response.GetListenerAggregationResponse;
import com.ccc.ari.global.contract.SubscriptionContract;
import com.ccc.ari.global.event.ArtistSettlementRequestedEvent;
import com.ccc.ari.global.event.RegularSettlementRequestedEvent;
import com.ccc.ari.subscription.ui.client.SubscriptionClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tx.gas.ContractGasProvider;
import org.web3j.tx.gas.StaticGasProvider;

import java.math.BigInteger;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SettlementExecuteService {

    private final SubscriptionContract subscriptionContract;
    private final StreamingCountClient streamingCountClient;
    private final SubscriptionClient subscriptionClient;

    private final Logger logger = LoggerFactory.getLogger(this.getClass());
    // 1 LINK = 10^18
    private final BigInteger LINK_MULTIPLIER = BigInteger.TEN.pow(18);
    // 정기 구독의 결제 금액은 1LINK
    private final BigInteger REGULAR_AMOUNT = BigInteger.ONE.multiply(LINK_MULTIPLIER);
    // 아티스트 구독의 결제 금액은 1LINK
    private final BigInteger ARTIST_AMOUNT = BigInteger.ONE.multiply(LINK_MULTIPLIER);

    /**
     * 정기 구독 정산 요청 이벤트를 처리하는 메서드
     *
     * @param event 정기 구독 정산 요청 이벤트 객체
     */
    @EventListener
    public void handleRegularSettlementRequestedEvent(RegularSettlementRequestedEvent event) {

        logger.info("정기 구독 정산 요청 이벤트 수신 - SubscriberId: {}, PeriodStart: {}, PeriodEnd: {}",
                event.getSubscriberId(), event.getPeriodStart(), event.getPeriodEnd());

        // 1. BigInteger(UTC) -> LocalDateTime(KST)으로 시간 변환
        LocalDateTime startTime = Instant.ofEpochSecond(event.getPeriodStart().longValue())
                .atZone(ZoneId.of("UTC"))
                .withZoneSameInstant(ZoneId.of("Asia/Seoul"))
                .toLocalDateTime();

        LocalDateTime endTime = Instant.ofEpochSecond(event.getPeriodEnd().longValue())
                .atZone(ZoneId.of("UTC"))
                .withZoneSameInstant(ZoneId.of("Asia/Seoul"))
                .toLocalDateTime();

        logger.info("정산 기간 변환 완료 - StartTime: {}, EndTime: {}", startTime, endTime);

        // 2. 해당 시간대의 가수별 스트리밍 카운트 조회
        GetListenerAggregationResponse response = null;
        try {
            response = streamingCountClient.getListenerAggregation(event.getSubscriberId(), startTime, endTime);
            logger.info("스트리밍 카운트 조회 성공 - ArtistCountList 크기: {}", response.getArtistCountList().size());
        } catch (Exception e) {
            logger.error("스트리밍 카운트 조회 중 오류 발생 - SubscriberId: {}", event.getSubscriberId(), e);
            return;
        }

        // 3. 해당 시간대에 해당하는 구독 사이클 조회
        Integer cycleId = subscriptionClient.getRegularSubscriptionCycleIdByPeriod(event.getSubscriberId(), startTime, endTime)
                    .getSubscriptionCycleId().getValue();
        logger.info("구독 사이클 조회 성공 - CycleId: {}", cycleId);

        // 4. 정기 구독 사이클 정산 컨트랙트 함수 실행
        List<BigInteger> artistIds = response.getArtistCountList().stream()
                .map(result -> BigInteger.valueOf(result.getArtistId()))
                .toList();

        List<BigInteger> streamingCounts = response.getArtistCountList().stream()
                .map(result -> BigInteger.valueOf(result.getCount()))
                .toList();

        try {
            // 가스 제공자 설정
            ContractGasProvider gasProvider = new StaticGasProvider(
                    BigInteger.valueOf(22_000_000_000L), // gasPrice
                    BigInteger.valueOf(8_000_000)        // gasLimit
            );

            // 컨트랙트에 가스 제공자 설정
            subscriptionContract.setGasProvider(gasProvider);

            TransactionReceipt receipt = subscriptionContract.settlePaymentsRegularByArtist(
                    BigInteger.valueOf(event.getSubscriberId()),
                    BigInteger.valueOf(cycleId),
                    REGULAR_AMOUNT,
                    artistIds,
                    streamingCounts
            ).send();

            logger.info("정기 구독 정산 컨트랙트 함수 호출 성공 - SubscriberId: {}, CycleId: {}, TransactionHash: {}",
                    event.getSubscriberId(), cycleId, receipt.getTransactionHash());

        } catch (Exception e) {
            logger.error("정기 구독 정산 실행 함수 호출 중 문제가 발생했습니다 - SubscriberId: {}, CycleId: {}",
                    event.getSubscriberId(), cycleId, e);
        }
    }

    /**
     * 아티스트 구독 정산 요청 이벤트를 처리하는 메서드
     *
     * @param event 아티스트 구독 정산 요청 이벤트 객체
     */
    @EventListener
    public void handleArtistSettlementRequestedEvent(ArtistSettlementRequestedEvent event) {

        logger.info("아티스트 구독 정산 요청 이벤트 수신 - SubscriberId: {}, artistId:{}, PeriodStart: {}, PeriodEnd: {}",
                event.getSubscriberId(), event.getArtistId(), event.getPeriodStart(), event.getPeriodEnd());

        // 1. BigInteger(UTC) -> LocalDateTime(KST)으로 시간 변환
        LocalDateTime startTime = Instant.ofEpochSecond(event.getPeriodStart().longValue())
                .atZone(ZoneId.of("UTC"))
                .withZoneSameInstant(ZoneId.of("Asia/Seoul"))
                .toLocalDateTime();

        LocalDateTime endTime = Instant.ofEpochSecond(event.getPeriodEnd().longValue())
                .atZone(ZoneId.of("UTC"))
                .withZoneSameInstant(ZoneId.of("Asia/Seoul"))
                .toLocalDateTime();

        logger.info("정산 기간 변환 완료 - StartTime: {}, EndTime: {}", startTime, endTime);

        // 2. 해당 시간대에 해당하는 구독 사이클 조회
        Integer cycleId = subscriptionClient.getArtistSubscriptionCycleIdByPeriod(event.getSubscriberId().intValue(),
                                                                                  event.getArtistId().intValue(),
                                                                                  startTime, endTime)
                .getSubscriptionCycleId().getValue();
        logger.info("구독 사이클 조회 성공 - CycleId: {}", cycleId);

        // 3. 아티스트 구독 사이클 정산 컨트랙트 함수 실행
        try {
            // 가스 제공자 설정
            ContractGasProvider gasProvider = new StaticGasProvider(
                    BigInteger.valueOf(22_000_000_000L), // gasPrice
                    BigInteger.valueOf(8_000_000)        // gasLimit
            );

            // 컨트랙트에 가스 제공자 설정
            subscriptionContract.setGasProvider(gasProvider);

            TransactionReceipt receipt = subscriptionContract.settlePaymentsArtist(
                    BigInteger.valueOf(event.getSubscriberId()),
                    BigInteger.valueOf(event.getArtistId()),
                    BigInteger.valueOf(cycleId),
                    ARTIST_AMOUNT
            ).send();

            logger.info("아티스트 구독 정산 컨트랙트 함수 호출 성공 - SubscriberId: {}, artistId: {}, CycleId: {}",
                    event.getSubscriberId(), event.getArtistId(), cycleId);
        } catch (Exception e) {
            logger.error("아티스트 구독 정산 실행 함수 호출 중 문제가 발생했습니다 - SubscriberId: {}, artistId: {}, CycleId: {}",
                    event.getSubscriberId(), event.getArtistId(), cycleId, e);
        }
    }
}
