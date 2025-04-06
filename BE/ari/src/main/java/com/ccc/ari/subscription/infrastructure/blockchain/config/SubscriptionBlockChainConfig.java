package com.ccc.ari.subscription.infrastructure.blockchain.config;

import com.ccc.ari.global.contract.SubscriptionContract;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.request.Transaction;
import org.web3j.protocol.websocket.WebSocketService;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

import java.math.BigInteger;

@Configuration("subscriptionBlockChainConfig")
public class SubscriptionBlockChainConfig {

    @Value("${SEPOLIA_WEBSOCKET_ENDPOINT}")
    private String blockchainWebSocketEndpoint;

    @Value("${SUBSCRIPTION_CONTRACT_ADDRESS}")
    private String subscriptionContractAddress;

    @Value("${OWNER_PRIVATE_KEY}")
    private String privateKey;

    @Value("${CHAIN_ID:11155111}")
    private long chainId;

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Bean(name = "subscriptionContractWeb3j")
    public Web3j web3j() throws Exception {
        logger.info("블록체인 노드 웹소켓 서비스 초기화 시작: {}", blockchainWebSocketEndpoint);
        WebSocketService webSocketService = new WebSocketService(blockchainWebSocketEndpoint, true);

        try {
            webSocketService.connect();
            logger.info("블록체인 노드 웹소켓 연결 성공");
        } catch (Exception e) {
            logger.error("블록체인 노드 웹소켓 연결 실패: {}", e.getMessage());
            throw e;
        }

        Web3j web3j = Web3j.build(webSocketService);
        logger.info("Web3j 웹소켓 클라이언트 초기화 완료");
        return web3j;
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
                return BigInteger.valueOf(5_000_000_000L); // 5 GWEI
            }

            @Override
            public BigInteger getGasLimit() {
                return BigInteger.valueOf(500_000L);
            }

            @Override
            public BigInteger getGasLimit(Transaction transaction) {
                return BigInteger.valueOf(500_000L);
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
}
