package com.ccc.ari.subscription.infrastructure.blockchain.adapter;

import com.ccc.ari.global.contract.SubscriptionContract;
import com.ccc.ari.subscription.event.ArtistSubscriptionOnChainCreatedEvent;
import com.ccc.ari.subscription.event.RegularSubscriptionOnChainCreatedEvent;
import com.ccc.ari.subscription.util.DecimalConverter;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
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
import org.web3j.protocol.core.DefaultBlockParameterName;

@Component
public class SubscriptionContractEventListner implements ApplicationListener<ApplicationReadyEvent> {

    private final Web3j web3j;
    private final SubscriptionContract subscriptionContract;
    private final ApplicationEventPublisher eventPublisher;
    private final PlatformTransactionManager transactionManager;
    private final Logger logger = LoggerFactory.getLogger(SubscriptionContractEventListner.class);

    @Autowired
    public SubscriptionContractEventListner(@Qualifier("subscriptionContractWeb3j") Web3j web3j,
                                            SubscriptionContract subscriptionContract,
                                            ApplicationEventPublisher eventPublisher,
                                            PlatformTransactionManager transactionManager) {
        this.web3j = web3j;
        this.subscriptionContract = subscriptionContract;
        this.eventPublisher = eventPublisher;
        this.transactionManager = transactionManager;
    }

    /**
     * 어플리케이션 초기화 완료 후 실행
     */
    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        logger.info("애플리케이션 초기화 완료 - 온체인 이벤트 구독 시작");
        subscribeToRegularSubscriptionCreatedEvent();
        subscribeToArtistSubscriptionCreatedEvent();
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

    @Async
    protected void handleRegularSubscriptionEvent(SubscriptionContract.RegularSubscriptionCreatedEventResponse event) {
        logger.info("정기 구독 생성 온체인 이벤트가 발생했습니다. 구독자 ID: {}", event.userId);

        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        transactionTemplate.execute(status -> {
            eventPublisher.publishEvent(
                    new RegularSubscriptionOnChainCreatedEvent(event.userId.intValue(),
                            DecimalConverter.fromSolidityDecimal(event.amount)));
            return null;
        });

        logger.info("RegularSubscriptionOnChainCreatedEvent가 성공적으로 발행되었습니다. userId: {}",
                event.userId.intValue());
    }

    @Async
    protected void handleArtistSubscriptionEvent(SubscriptionContract.ArtistSubscriptionCreatedEventResponse event) {
        logger.info("아티스트 구독 생성 온체인 이벤트가 발생했습니다. 구독자 ID: {}", event.subscriberId);

        eventPublisher.publishEvent(
                new ArtistSubscriptionOnChainCreatedEvent(event.subscriberId.intValue(),
                        event.artistId.intValue(),
                        DecimalConverter.fromSolidityDecimal(event.amount)));

        logger.info("ArtistSubscriptionOnChainCreatedEvent가 성공적으로 발행되었습니다. subscriberId: {}, artistId: {}",
                event.subscriberId.intValue(), event.artistId.intValue());
    }
}
