package com.ccc.ari.subscription.infrastructure.blockchain.adapter;

import com.ccc.ari.global.contract.SubscriptionContract;
import com.ccc.ari.global.event.ArtistSettlementRequestedEvent;
import com.ccc.ari.global.event.RegularSettlementRequestedEvent;
import com.ccc.ari.global.type.EventType;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.subscription.domain.repository.BlockNumberRepository;
import com.ccc.ari.subscription.domain.repository.SubscriptionEventRepository;
import com.ccc.ari.subscription.event.OnChainArtistPaymentProcessedEvent;
import com.ccc.ari.subscription.event.OnChainArtistSubscriptionCreatedEvent;
import com.ccc.ari.subscription.event.OnChainRegularPaymentProcessedEvent;
import com.ccc.ari.subscription.event.OnChainRegularSubscriptionCreatedEvent;
import com.ccc.ari.subscription.util.DecimalConverter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameter;
import org.web3j.protocol.core.DefaultBlockParameterName;

import java.math.BigInteger;

@Component
public class SubscriptionContractEventListner implements ApplicationListener<ApplicationReadyEvent> {

    private final Web3j web3j;
    private final SubscriptionContract subscriptionContract;
    private final SubscriptionEventRepository subscriptionEventRepository;
    private final BlockNumberRepository blockNumberRepository;

    private final ApplicationEventPublisher eventPublisher;
    private final PlatformTransactionManager transactionManager;
    private final Logger logger = LoggerFactory.getLogger(SubscriptionContractEventListner.class);

    // 재구독 결제 완료 이벤트 ID
    private final String PAYMENT_PROCESSED_REGULAR = "PaymentProcessedRegular";
    private final String PAYMENT_PROCESSED_ARTIST = "PaymentProcessedArtist";
    // 정산 요청 이벤트 ID
    private final String SETTLEMENT_REQUESTED_REGULAR = "SettlementRequestedRegular";
    private final String SETTLEMENT_REQUESTED_ARTIST = "SettlementRequestedArtist";

    @Autowired
    public SubscriptionContractEventListner(@Qualifier("subscriptionContractWeb3j") Web3j web3j,
                                            SubscriptionContract subscriptionContract,
                                            ApplicationEventPublisher eventPublisher,
                                            PlatformTransactionManager transactionManager,
                                            SubscriptionEventRepository subscriptionEventRepository,
                                            BlockNumberRepository blockNumberRepository) {
        this.web3j = web3j;
        this.subscriptionContract = subscriptionContract;
        this.eventPublisher = eventPublisher;
        this.transactionManager = transactionManager;
        this.subscriptionEventRepository = subscriptionEventRepository;
        this.blockNumberRepository = blockNumberRepository;
    }

    /**
     * 어플리케이션 초기화 완료 후 실행
     */
    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        logger.info("애플리케이션 초기화 완료 - 온체인 이벤트 구독 시작");
        // 구독 생성 컨트랙트 이벤트
        subscribeToRegularSubscriptionCreatedEvent();
        subscribeToArtistSubscriptionCreatedEvent();
        // 구독 결제 완료 컨트랙트 이벤트
        subscribeToPaymentProcessedRegularEvent();
        subscribeToPaymentProcessedArtistEvent();
        // 정산 요청 컨트랙트 이벤트
        subscribeToSettlementRequestedRegularEvent();
        subscribeToSettlementRequestedArtistEvent();
    }

    /**
     * 구독 컨트랙트의 새롭게 발생하는 RegularSubscriptionCreatedEvent를 감지하여 조회하고
     * RegularSubscriptionOnChainCreatedEvent를 발행하는 메소드를 호출합니다.
     */
    public void subscribeToRegularSubscriptionCreatedEvent() {

        subscriptionContract.regularSubscriptionCreatedEventFlowable(
                DefaultBlockParameterName.EARLIEST,
                DefaultBlockParameterName.LATEST)
            .subscribe(event -> {
                // 이벤트가 발생하면 이벤트 데이터가 event 객체에 담겨 옵니다.
                // 비동기로 이벤트 처리
                handleRegularSubscriptionEvent(event);
            }, error -> {
                logger.error("정기 구독 생성 이벤트 구독 중 오류가 발생했습니다.", error);
            });
    }

    /**
     * 구독 컨트랙트의 새롭게 발생하는 ArtistSubscriptionCreatedEvent를 감지하여 조회하고
     * ArtistSubscriptionOnChainCreatedEvent를 발행하는 메소드를 호출합니다.
     */
    public void subscribeToArtistSubscriptionCreatedEvent() {

        subscriptionContract.artistSubscriptionCreatedEventFlowable(
                    DefaultBlockParameterName.EARLIEST,
                    DefaultBlockParameterName.LATEST)
            .subscribe(event -> {
                // 이벤트가 발생하면 이벤트 데이터가 event 객체에 담겨 옵니다.
                // 비동기로 이벤트 처리
                handleArtistSubscriptionEvent(event);
            }, error -> {
                logger.error("아티스트 구독 생성 이벤트 구독 중 오류가 발생했습니다.", error);
            });
    }

    /**
     * 구독 컨트랙트의 PaymentProcessedRegularEvent를 감시하며 처리한 블록의 번호를 저장합니다.
     * 마지막으로 처리한 블록부터 이벤트를 처리해 서버 재구동 시에도 이벤트의 중복 처리를 방지합니다.
     */
    public void subscribeToPaymentProcessedRegularEvent() {

        BigInteger lastProcessedBlock =
                blockNumberRepository.getLastProcessedBlockNumber(PAYMENT_PROCESSED_REGULAR).orElse(null);

        DefaultBlockParameter fromBlock;
        if (lastProcessedBlock == null) {
            logger.info("이전에 처리된 정기 구독 결제 완료 블록 정보 없음. 첫 블록부터 시작합니다.");
            fromBlock = DefaultBlockParameterName.EARLIEST;
        } else {
            logger.info("이전에 처리된 정기 구독 결제 완료 마지막 블록 번호: {}. 해당 블록부터 구독 시작", lastProcessedBlock);
            // 마지막 블록부터 다시 시작하여 블록 내 이벤트 누락 방지
            fromBlock = DefaultBlockParameter.valueOf(lastProcessedBlock);
        }

        subscriptionContract.paymentProcessedRegularEventFlowable(
                        fromBlock,
                        DefaultBlockParameterName.LATEST)
                .subscribe(event -> {
                    String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();
                    logger.info("새로운 PaymentProcessedRegular 이벤트 감지. Event ID: {}", eventId);

                    if (!subscriptionEventRepository.existsBySubscriptionEventIdAndEventTypeP(eventId)) {
                        logger.info("처리되지 않은 새로운 정기 구독 결제 완료 이벤트(Event ID: {})입니다. 처리 시작.", eventId);
                        handlePaymentProcessedRegularEvent(event);

                        subscriptionEventRepository.save(eventId, EventType.P, event.userId.intValue(), PlanType.R);
                        logger.info("정기 구독 결제 완료 이벤트(ID: {})를 저장했습니다.", eventId);
                    } else {
                        logger.info("Event ID {}는 이미 처리된 정기 구독 결제 완료 이벤트입니다. 처리 건너뜀.", eventId);
                    }

                    BigInteger currentBlock = event.log.getBlockNumber();
                    BigInteger savedBlock =
                            blockNumberRepository.getLastProcessedBlockNumber(PAYMENT_PROCESSED_REGULAR).orElse(null);

                    if (savedBlock == null || currentBlock.compareTo(savedBlock) > 0) {
                        blockNumberRepository.saveLastProcessedBlock(PAYMENT_PROCESSED_REGULAR, currentBlock);
                        logger.info("정기 구독 결제 완료 이벤트의 마지막 처리 블록 번호를 {}로 업데이트했습니다.", currentBlock);
                    }
                }, error -> {
                    logger.error("정기 구독 결제 완료 이벤트 구독 중 오류가 발생했습니다.", error);
                });
    }

    /**
     * 구독 컨트랙트의 PaymentProcessedArtistEvent를 감시하며 처리한 블록의 번호를 저장합니다.
     * 마지막으로 처리한 블록부터 이벤트를 처리해 서버 재구동 시에도 이벤트의 중복 처리를 방지합니다.
     */
    public void subscribeToPaymentProcessedArtistEvent() {

        BigInteger lastProcessedBlock =
                blockNumberRepository.getLastProcessedBlockNumber(PAYMENT_PROCESSED_ARTIST).orElse(null);

        DefaultBlockParameter fromBlock;
        if (lastProcessedBlock == null) {
            logger.info("이전에 처리된 아티스트 구독 결제 완료 블록 정보 없음. 첫 블록부터 시작합니다.");
            fromBlock = DefaultBlockParameterName.EARLIEST;
        } else {
            logger.info("이전에 처리된 아티스트 구독 결제 완료 마지막 블록 번호: {}. 해당 블록부터 구독 시작", lastProcessedBlock);
            // 마지막 블록부터 다시 시작하여 블록 내 이벤트 누락 방지
            fromBlock = DefaultBlockParameter.valueOf(lastProcessedBlock);
        }

        subscriptionContract.paymentProcessedArtistEventFlowable(
                        fromBlock,
                        DefaultBlockParameterName.LATEST)
                .subscribe(event -> {
                    String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();
                    logger.info("새로운 PaymentProcessedArtist 이벤트 감지. Event ID: {}", eventId);

                    if (!subscriptionEventRepository.existsBySubscriptionEventIdAndEventTypeP(eventId)) {
                        logger.info("처리되지 않은 새로운 아티스트 구독 결제 완료 이벤트(Event ID: {})입니다. 처리 시작.", eventId);
                        handlePaymentProcessedArtistEvent(event);

                        subscriptionEventRepository.save(eventId, EventType.P, event.userId.intValue(), PlanType.A);
                        logger.info("아티스트 구독 결제 완료 이벤트(ID: {})를 저장했습니다.", eventId);
                    } else {
                        logger.info("Event ID {}는 이미 처리된 아티스트 구독 결제 완료 이벤트입니다. 처리 건너뜀.", eventId);
                    }

                    BigInteger currentBlock = event.log.getBlockNumber();
                    BigInteger savedBlock =
                            blockNumberRepository.getLastProcessedBlockNumber(PAYMENT_PROCESSED_ARTIST).orElse(null);

                    if (savedBlock == null || currentBlock.compareTo(savedBlock) > 0) {
                        blockNumberRepository.saveLastProcessedBlock(PAYMENT_PROCESSED_ARTIST, currentBlock);
                        logger.info("아티스트 구독 결제 완료 이벤트의 마지막 처리 블록 번호를 {}로 업데이트했습니다.", currentBlock);
                    }
                }, error -> {
                    logger.error("아티스트 구독 결제 완료 이벤트 구독 중 오류가 발생했습니다.", error);
                });
    }

    /**
     * 구독 컨트랙트의 정기 구독 정산 요청 이벤트를 감시하며 처리한 블록의 번호를 저장합니다.
     * 마지막으로 처리한 블록부터 이벤트를 처리해 서버 재구동 시에도 이벤트의 중복 처리를 방지합니다.
     */
    public void subscribeToSettlementRequestedRegularEvent() {

        BigInteger lastProcessedBlock =
                blockNumberRepository.getLastProcessedBlockNumber(SETTLEMENT_REQUESTED_REGULAR).orElse(null);

        DefaultBlockParameter fromBlock;
        if (lastProcessedBlock == null) {
            logger.info("이전에 처리된 정기 구독 정산 요청 블록 정보 없음. 첫 블록부터 시작합니다.");
            fromBlock = DefaultBlockParameterName.EARLIEST;
        } else {
            logger.info("이전에 처리된 정기 구독 정산 요청 마지막 블록 번호: {}. 해당 블록부터 구독 시작",
                    lastProcessedBlock);
            fromBlock = DefaultBlockParameter.valueOf(lastProcessedBlock);
        }

        subscriptionContract.settlementRequestedRegularEventFlowable(
                        fromBlock,
                        DefaultBlockParameterName.LATEST)
                .subscribe(event -> {
                    String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();
                    logger.info("새로운 SettlementRequestedRegular 이벤트 감지. Event ID: {}", eventId);

                    if (!subscriptionEventRepository.existsBySubscriptionEventIdAndEventTypeS(eventId)) {
                        logger.info("처리되지 않은 새로운 정기 구독 정산 요청 이벤트(Event ID: {})입니다. 처리 시작.", eventId);
                        handleSettlementRequestedRegularEvent(event);

                        subscriptionEventRepository.save(eventId, EventType.S, event.userId.intValue(), PlanType.R);
                        logger.info("정기 구독 정산 요청 이벤트(ID: {})를 저장했습니다.", eventId);
                    } else {
                        logger.info("Event ID {}는 이미 처리된 정기 구독 정산 요청 이벤트입니다. 처리 건너뜀.", eventId);
                    }

                    BigInteger currentBlock = event.log.getBlockNumber();
                    BigInteger savedBlock =
                            blockNumberRepository.getLastProcessedBlockNumber(SETTLEMENT_REQUESTED_REGULAR).orElse(null);

                    if (savedBlock == null || currentBlock.compareTo(savedBlock) > 0) {
                        blockNumberRepository.saveLastProcessedBlock(SETTLEMENT_REQUESTED_REGULAR, currentBlock);
                        logger.info("정기 구독 정산 요청 이벤트의 마지막 처리 블록 번호를 {}로 업데이트했습니다.", currentBlock);
                    }
                }, error -> {
                    logger.error("정기 구독 정산 요청 이벤트 구독 중 오류가 발생했습니다.", error);
                });
    }

    /**
     * 구독 컨트랙트의 아티스트 구독 정산 요청 이벤트를 감시하며 처리한 블록의 번호를 저장합니다.
     * 마지막으로 처리한 블록부터 이벤트를 처리해 서버 재구동 시에도 이벤트의 중복 처리를 방지합니다.
     */
    public void subscribeToSettlementRequestedArtistEvent() {

        BigInteger lastProcessedBlock =
                blockNumberRepository.getLastProcessedBlockNumber(SETTLEMENT_REQUESTED_ARTIST).orElse(null);

        DefaultBlockParameter fromBlock;
        if (lastProcessedBlock == null) {
            logger.info("이전에 처리된 아티스트 구독 정산 요청 블록 정보 없음. 첫 블록부터 시작합니다.");
            fromBlock = DefaultBlockParameterName.EARLIEST;
        } else {
            logger.info("이전에 처리된 아티스트 구독 정산 요청 마지막 블록 번호: {}. 해당 블록부터 구독 시작",
                    lastProcessedBlock);
            fromBlock = DefaultBlockParameter.valueOf(lastProcessedBlock);
        }

        subscriptionContract.settlementRequestedArtistEventFlowable(
                        fromBlock,
                        DefaultBlockParameterName.LATEST)
                .subscribe(event -> {
                    String eventId = event.log.getTransactionHash() + "-" + event.log.getLogIndex();
                    logger.info("새로운 SettlementRequestedArtist 이벤트 감지. Event ID: {}", eventId);

                    if (!subscriptionEventRepository.existsBySubscriptionEventIdAndEventTypeS(eventId)) {
                        logger.info("처리되지 않은 새로운 아티스트 구독 정산 요청 이벤트(Event ID: {})입니다. 처리 시작.", eventId);
                        handleSettlementRequestedArtistEvent(event);

                        subscriptionEventRepository.save(eventId, EventType.S, event.subscriberId.intValue(), PlanType.A);
                        logger.info("아티스트 구독 정산 요청 이벤트(ID: {})를 저장했습니다.", eventId);
                    } else {
                        logger.info("Event ID {}는 이미 처리된 아티스트 구독 정산 요청 이벤트입니다. 처리 건너뜀.", eventId);
                    }

                    BigInteger currentBlock = event.log.getBlockNumber();
                    BigInteger savedBlock =
                            blockNumberRepository.getLastProcessedBlockNumber(SETTLEMENT_REQUESTED_ARTIST).orElse(null);

                    if (savedBlock == null || currentBlock.compareTo(savedBlock) > 0) {
                        blockNumberRepository.saveLastProcessedBlock(SETTLEMENT_REQUESTED_ARTIST, currentBlock);
                        logger.info("아티스트 구독 정산 요청 이벤트의 마지막 처리 블록 번호를 {}로 업데이트했습니다.", currentBlock);
                    }
                }, error -> {
                    logger.error("아티스트 구독 정산 요청 이벤트 구독 중 오류가 발생했습니다.", error);
                });
    }

    @Async
    protected void handleRegularSubscriptionEvent(SubscriptionContract.RegularSubscriptionCreatedEventResponse event) {
        logger.info("정기 구독 생성 온체인 이벤트가 발생했습니다. 구독자 ID: {}", event.userId);

        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        transactionTemplate.execute(status -> {
            eventPublisher.publishEvent(
                    new OnChainRegularSubscriptionCreatedEvent(event.userId.intValue(),
                            DecimalConverter.fromSolidityDecimal(event.amount)));
            return null;
        });

        logger.info("OnChainRegularSubscriptionCreatedEvent가 성공적으로 발행되었습니다. userId: {}",
                event.userId.intValue());
    }

    @Async
    protected void handleArtistSubscriptionEvent(SubscriptionContract.ArtistSubscriptionCreatedEventResponse event) {
        logger.info("아티스트 구독 생성 온체인 이벤트가 발생했습니다. 구독자 ID: {}", event.subscriberId);

        eventPublisher.publishEvent(
                new OnChainArtistSubscriptionCreatedEvent(event.subscriberId.intValue(),
                        event.artistId.intValue(),
                        DecimalConverter.fromSolidityDecimal(event.amount)));

        logger.info("OnChainArtistSubscriptionCreatedEvent가 성공적으로 발행되었습니다. subscriberId: {}, artistId: {}",
                event.subscriberId.intValue(), event.artistId.intValue());
    }

    @Async
    protected void handlePaymentProcessedRegularEvent(SubscriptionContract.PaymentProcessedRegularEventResponse event) {
        logger.info("정기 구독 결제 완료 온체인 이벤트가 발생했습니다. 구독자 ID: {}", event.userId);

        eventPublisher.publishEvent(
                new OnChainRegularPaymentProcessedEvent(event.userId.intValue()));

        logger.info("OnChainRegularPaymentProcessedEvent가 성공적으로 발행되었습니다. 구독자 ID: {}",
                event.userId.intValue());
    }

    @Async
    protected void handlePaymentProcessedArtistEvent(SubscriptionContract.PaymentProcessedArtistEventResponse event) {
        logger.info("아티스트 구독 결제 완료 온체인 이벤트가 발생했습니다. 구독자 ID: {}, 아티스트 ID: {}",
                event.userId, event.artistId);

        eventPublisher.publishEvent(
                new OnChainArtistPaymentProcessedEvent(event.userId.intValue(), event.artistId.intValue()));

        logger.info("OnChainArtistPaymentProcessedEvent가 성공적으로 발행되었습니다. 구독자 ID: {}, 아티스트 ID: {}",
                event.userId.intValue(), event.artistId.intValue());
    }

    @Async
    protected void handleSettlementRequestedRegularEvent(SubscriptionContract.SettlementRequestedRegularEventResponse event) {
        logger.info("정기 구독 정산 요청 온체인 이벤트가 발생했습니다. 구독자 ID: {}", event.userId);

        eventPublisher.publishEvent(new RegularSettlementRequestedEvent(event.userId.intValue(),
                                                                        event.periodStart, event.periodEnd));
        logger.info("RegularSettlementRequestedEvent가 성공적으로 발행되었습니다. 구독자 ID: {}",
                event.userId.intValue());
    }

    @Async
    protected void handleSettlementRequestedArtistEvent(SubscriptionContract.SettlementRequestedArtistEventResponse event) {
        logger.info("아티스트 구독 정산 요청 온체인 이벤트가 발생했습니다. 구독자 ID: {}, 아티스트 ID:{}",
                event.subscriberId, event.artistId);

        eventPublisher.publishEvent(new ArtistSettlementRequestedEvent(event.subscriberId.intValue(),
                                                                       event.artistId.intValue(),
                                                                       event.periodStart, event.periodEnd));
        logger.info("ArtistSettlementRequestedEvent가 성공적으로 발행되었습니다. 구독자 ID: {}, 아티스트 ID:{}",
                event.subscriberId, event.artistId);
    }
}
