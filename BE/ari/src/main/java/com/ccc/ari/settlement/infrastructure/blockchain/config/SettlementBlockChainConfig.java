package com.ccc.ari.settlement.infrastructure.blockchain.config;

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
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

import java.math.BigInteger;

@Configuration("settlementBlockChainConfig")
public class SettlementBlockChainConfig {

    @Value("${SEPOLIA_NODE_ENDPOINT}")
    private String blockchainHttpEndpoint;

    @Value("${SUBSCRIPTION_CONTRACT_ADDRESS}")
    private String subscriptionContractAddress;

    @Value("${OWNER_PRIVATE_KEY}")
    private String privateKey;

    @Value("${CHAIN_ID:11155111}")
    private long chainId;

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Bean(name = "settlementContractWeb3j")
    public Web3j web3j() {
        logger.info("블록체인 노드 HTTP 서비스 초기화 시작: {}", blockchainHttpEndpoint);
        Web3j web3j = Web3j.build(new HttpService(blockchainHttpEndpoint));
        logger.info("Web3j HTTP 클라이언트 초기화 완료");
        return web3j;
    }

    @Bean(name = "settlementContractTransactionManager")
    public TransactionManager transactionManager(@Qualifier("settlementContractWeb3j") Web3j web3j) {
        Credentials credentials = Credentials.create(privateKey);
        return new RawTransactionManager(web3j, credentials, chainId);
    }

    @Bean(name = "settlementContractGasProvider")
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
    public SubscriptionContract settlementContract(
            @Qualifier("settlementContractWeb3j") Web3j web3j,
            @Qualifier("settlementContractTransactionManager") TransactionManager transactionManager,
            @Qualifier("settlementContractGasProvider") ContractGasProvider contractGasProvider) {
        return SubscriptionContract.load(subscriptionContractAddress,
                web3j, transactionManager, contractGasProvider);
    }
}
