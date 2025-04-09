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
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionException;
import java.util.concurrent.TimeUnit;

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
    private static final int MAX_RETRY_ATTEMPTS = 5;
    private static final long RETRY_DELAY_MS = 2000;
    private static final BigInteger GAS_PRICE_INCREMENT = BigInteger.valueOf(5_000_000_000L); // 5 Gwei
    private static final BigInteger INITIAL_GAS_PRICE = BigInteger.valueOf(22_000_000_000L);
    private static final BigInteger GAS_LIMIT = BigInteger.valueOf(8_000_000);
    private static final long TRANSACTION_TIMEOUT_SECONDS = 60;

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
            response.getArtistCountList().forEach(
                    artistData -> logger.info("스트리밍 카운트 조회 성공 - ArtistId: {}, Count: {}",
                            artistData.getArtistId(), artistData.getCount())
            );
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

        // 5. 입력값 유효성 검사
        if (artistIds.isEmpty() || streamingCounts.isEmpty()) {
            logger.error("스트리밍 카운트 데이터가 비어있습니다 - SubscriberId: {}", event.getSubscriberId());
            return;
        }

        try {
            TransactionReceipt receipt = executeWithRetry(
                    "정기 구독 정산",
                    event.getSubscriberId().longValue(),
                    () -> subscriptionContract.settlePaymentsRegularByArtist(
                            BigInteger.valueOf(event.getSubscriberId()),
                            BigInteger.valueOf(cycleId),
                            REGULAR_AMOUNT,
                            artistIds,
                            streamingCounts
                    ).send()
            );
        } catch (Exception e) {
            logger.error("정기 구독 정산 최종 실패 - SubscriberId: {}, CycleId: {}",
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
            TransactionReceipt receipt = executeWithRetry(
                    "아티스트 구독 정산",
                    event.getSubscriberId().longValue(),
                    () -> subscriptionContract.settlePaymentsArtist(
                            BigInteger.valueOf(event.getSubscriberId()),
                            BigInteger.valueOf(event.getArtistId()),
                            BigInteger.valueOf(cycleId),
                            ARTIST_AMOUNT
                    ).send()
            );
        } catch (Exception e) {
            logger.error("아티스트 구독 정산 최종 실패 - SubscriberId: {}, ArtistId: {}, CycleId: {}",
                    event.getSubscriberId(), event.getArtistId(), cycleId, e);
        }
    }

    private TransactionReceipt executeWithRetry(String operationType,
                                                Long subscriberId,
                                                TransactionExecutor executor) {
        Exception lastException = null;
        BigInteger currentGasPrice = INITIAL_GAS_PRICE;

        for (int attempt = 0; attempt < MAX_RETRY_ATTEMPTS; attempt++) {
            try {
                ContractGasProvider gasProvider = new StaticGasProvider(currentGasPrice, GAS_LIMIT);
                subscriptionContract.setGasProvider(gasProvider);

                CompletableFuture<TransactionReceipt> future = CompletableFuture.supplyAsync(() -> {
                    try {
                        return executor.execute();
                    } catch (Exception e) {
                        throw new CompletionException(e);
                    }
                });

                TransactionReceipt receipt = future.get(TRANSACTION_TIMEOUT_SECONDS, TimeUnit.SECONDS);

                if (!receipt.isStatusOK()) {
                    throw new RuntimeException("트랜잭션이 실패했습니다. Status: " + receipt.getStatus());
                }

                logger.info("{} 트랜잭션 성공 - SubscriberId: {}, GasPrice: {}, GasUsed: {}, Hash: {}",
                        operationType, subscriberId, currentGasPrice, receipt.getGasUsed(), receipt.getTransactionHash());

                return receipt;

            } catch (Exception e) {
                lastException = e;
                logger.warn("{} 시도 #{} 실패 - SubscriberId: {}, GasPrice: {}",
                        operationType, attempt + 1, subscriberId, currentGasPrice, e);

                if (attempt < MAX_RETRY_ATTEMPTS - 1) {
                    currentGasPrice = currentGasPrice.add(GAS_PRICE_INCREMENT);
                    try {
                        Thread.sleep(RETRY_DELAY_MS);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("재시도 중 인터럽트 발생", ie);
                    }
                }
            }
        }

        throw new RuntimeException("최대 재시도 횟수 초과로 트랜잭션 실패", lastException);
    }

    @FunctionalInterface
    private interface TransactionExecutor {
        TransactionReceipt execute() throws Exception;
    }
}
