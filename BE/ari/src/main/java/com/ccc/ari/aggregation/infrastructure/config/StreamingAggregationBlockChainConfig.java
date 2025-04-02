package com.ccc.ari.aggregation.infrastructure.config;

import com.ccc.ari.global.contract.StreamingAggregationContract;
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

@Configuration("StreamingAggregationBlockChainConfig")
public class StreamingAggregationBlockChainConfig {

    @Value("${SEPOLIA_NODE_ENDPOINT}")
    private String blockchainHttpEndpoint;

    @Value("${STREAMING_AGGREGATION_CONTRACT_ADDRESS}")
    private String streamingAggregationContractAddress;

    @Value("${OWNER_PRIVATE_KEY}")
    private String privateKey;

    // EIP-155 체인 ID
    @Value("${CHAIN_ID:11155111}")
    private long chainId;

    @Bean(name = "streamingAggregationContractWeb3j")
    public Web3j web3j() {
        return Web3j.build(new HttpService(blockchainHttpEndpoint));
    }

    @Bean(name = "streamingAggregationContractTransactionManager")
    public TransactionManager transactionManager(@Qualifier("streamingAggregationContractWeb3j") Web3j web3j) {
        // privateKey를 사용하여 Credentials 생성
        Credentials credentials = Credentials.create(privateKey);
        return new RawTransactionManager(web3j, credentials, chainId);
    }

    @Bean(name = "streamingAggregationContractGasProvider")
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
    public StreamingAggregationContract streamingAggregationContract(
            @Qualifier("streamingAggregationContractWeb3j") Web3j web3j,
            @Qualifier("streamingAggregationContractTransactionManager") TransactionManager transactionManager,
            @Qualifier("streamingAggregationContractGasProvider") ContractGasProvider contractGasProvider) {
        return StreamingAggregationContract.load(streamingAggregationContractAddress,
                web3j, transactionManager, contractGasProvider);
    }
}
