package com.ccc.ari.subscription.infrastructure.blockchain.config;

import com.ccc.ari.global.contract.SubscriptionContract;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.Web3ClientVersion;
import org.web3j.protocol.core.methods.request.Transaction;
import org.web3j.protocol.websocket.WebSocketService;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

import java.io.IOException;
import java.math.BigInteger;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

@Configuration("subscriptionBlockChainConfig")
@EnableScheduling
public class SubscriptionBlockChainConfig {

    @Value("${SEPOLIA_WEBSOCKET_ENDPOINT}")
    private String blockchainWebSocketEndpoint;

    @Value("${SUBSCRIPTION_CONTRACT_ADDRESS}")
    private String subscriptionContractAddress;

    @Value("${OWNER_PRIVATE_KEY}")
    private String privateKey;

    @Value("${CHAIN_ID:11155111}")
    private long chainId;

    @Value("${WEBSOCKET_RECONNECT_DELAY:30000}")
    private long reconnectDelay; // 재연결 대기 시간 (기본값: 30초)

    @Value("${WEBSOCKET_MAX_RECONNECT_ATTEMPTS:5}")
    private int maxReconnectAttempts; // 최대 재연결 시도 횟수 (기본값: 5회)

    private final Logger logger = LoggerFactory.getLogger(this.getClass());
    private final AtomicReference<WebSocketService> webSocketServiceRef = new AtomicReference<>();
    private final AtomicReference<Web3j> web3jRef = new AtomicReference<>();
    private final AtomicBoolean isReconnecting = new AtomicBoolean(false);
    private int reconnectAttempts = 0;

    @Bean(name = "subscriptionContractWeb3j")
    public Web3j web3j() throws Exception {
        logger.info("블록체인 노드 웹소켓 서비스 초기화 시작: {}", blockchainWebSocketEndpoint);
        WebSocketService webSocketService = createWebSocketService();
        Web3j web3j = Web3j.build(webSocketService);

        webSocketServiceRef.set(webSocketService);
        web3jRef.set(web3j);

        logger.info("Web3j 웹소켓 클라이언트 초기화 완료");
        return web3j;
    }

    private WebSocketService createWebSocketService() throws Exception {
        WebSocketService webSocketService = new WebSocketService(blockchainWebSocketEndpoint, true);

        try {
            webSocketService.connect();
            reconnectAttempts = 0; // 연결 성공 시 시도 횟수 초기화
            logger.info("블록체인 노드 웹소켓 연결 성공");
        } catch (Exception e) {
            logger.error("블록체인 노드 웹소켓 연결 실패: {}", e.getMessage());
            throw e;
        }

        return webSocketService;
    }

    @Bean(name = "subscriptionContractTransactionManager")
    public TransactionManager transactionManager(@Qualifier("subscriptionContractWeb3j") Web3j web3j) {
        // privateKey를 사용하여 Credentials 생성
        Credentials credentials = Credentials.create(privateKey);
        return new RawTransactionManager(web3j, credentials, chainId);
    }

    @Bean(name = "subscriptionContractGasProvider")
    public ContractGasProvider contractGasProvider() {
        return new ContractGasProvider() {
            @Override
            public BigInteger getGasPrice() {
                return BigInteger.valueOf(22_000_000_000L); // 22 GWEI
            }

            @Override
            public BigInteger getGasLimit() {
                return BigInteger.valueOf(3_000_000L);
            }

            @Override
            public BigInteger getGasLimit(Transaction transaction) {
                return BigInteger.valueOf(3_000_000L);
            }
        };
    }

    @Bean
    public SubscriptionContract subscriptionContract(
            @Qualifier("subscriptionContractWeb3j") Web3j web3j,
            @Qualifier("subscriptionContractTransactionManager") TransactionManager transactionManager,
            @Qualifier("subscriptionContractGasProvider") ContractGasProvider contractGasProvider) {
        return SubscriptionContract.load(subscriptionContractAddress,
                web3j, transactionManager, contractGasProvider);
    }

    /**
     * 웹소켓 연결 상태를 주기적으로 확인하는 스케줄링 메서드
     * 기본값으로 30초마다 실행
     */
    @Scheduled(fixedDelayString = "${WEBSOCKET_HEALTH_CHECK_INTERVAL:30000}")
    public void checkWebSocketConnection() {
        if (isReconnecting.get()) {
            logger.debug("이미 재연결 시도 중입니다. 중복 헬스체크를 건너뜁니다.");
            return;
        }

        Web3j web3j = web3jRef.get();
        if (web3j == null) {
            logger.warn("Web3j 인스턴스가 초기화되지 않았습니다.");
            return;
        }

        try {
            // 블록체인 노드 버전 조회로 연결 상태 확인
            Web3ClientVersion clientVersion = web3j.web3ClientVersion().send();
            logger.debug("웹소켓 연결 정상. 클라이언트 버전: {}", clientVersion.getWeb3ClientVersion());
        } catch (IOException e) {
            logger.warn("웹소켓 연결 상태 확인 실패: {}", e.getMessage());
            attemptReconnect();
        }
    }

    /**
     * 웹소켓 재연결 시도
     */
    private void attemptReconnect() {
        if (isReconnecting.compareAndSet(false, true)) {
            try {
                if (reconnectAttempts >= maxReconnectAttempts) {
                    logger.error("최대 재연결 시도 횟수 초과 ({}회). 재연결 중단", maxReconnectAttempts);
                    return;
                }

                reconnectAttempts++;
                logger.info("웹소켓 재연결 시도 중... (시도 {}회/{}회)", reconnectAttempts, maxReconnectAttempts);

                // 기존 연결 정리
                closeExistingConnection();

                // 새 웹소켓 서비스 생성 및 연결
                WebSocketService newWebSocketService = new WebSocketService(blockchainWebSocketEndpoint, true);
                newWebSocketService.connect();

                // 새 Web3j 인스턴스 생성
                Web3j newWeb3j = Web3j.build(newWebSocketService);

                // 테스트 호출로 연결 확인
                Web3ClientVersion clientVersion = newWeb3j.web3ClientVersion().send();
                logger.info("웹소켓 재연결 성공. 클라이언트 버전: {}", clientVersion.getWeb3ClientVersion());

                // 새 인스턴스로 교체
                WebSocketService oldWebSocketService = webSocketServiceRef.getAndSet(newWebSocketService);
                Web3j oldWeb3j = web3jRef.getAndSet(newWeb3j);

                // 이전 인스턴스 종료
                if (oldWeb3j != null) {
                    oldWeb3j.shutdown();
                }

                reconnectAttempts = 0; // 성공적인 재연결 후 카운터 초기화
            } catch (Exception e) {
                logger.error("웹소켓 재연결 실패: {}", e.getMessage());

                // 재연결 실패 시 지수 백오프 적용하여 재시도 (선택 사항)
                long delayWithBackoff = reconnectDelay * (long)Math.pow(2, reconnectAttempts - 1);
                logger.info("{}ms 후 재연결 재시도 예정", delayWithBackoff);

                try {
                    Thread.sleep(delayWithBackoff);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                }
            } finally {
                isReconnecting.set(false);
            }
        }
    }

    /**
     * 기존 웹소켓 연결 종료
     */
    private void closeExistingConnection() {
        WebSocketService oldWebSocketService = webSocketServiceRef.get();
        if (oldWebSocketService != null) {
            oldWebSocketService.close();
            logger.debug("이전 웹소켓 연결 종료 완료");
        }
    }

    /**
     * 애플리케이션 종료 시 리소스 정리
     */
    @PreDestroy
    public void cleanup() {
        logger.info("웹소켓 리소스 정리 중...");

        Web3j web3j = web3jRef.get();
        if (web3j != null) {
            web3j.shutdown();
            logger.info("Web3j 인스턴스 종료 완료");
        }

        WebSocketService webSocketService = webSocketServiceRef.get();
        if (webSocketService != null) {
            webSocketService.close();
            logger.info("웹소켓 서비스 종료 완료");
        }
    }
}