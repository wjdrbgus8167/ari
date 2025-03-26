package com.ccc.ari.aggregation.infrastructure.config;

import com.ccc.ari.global.contract.StreamingAggregationContract;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

import java.math.BigInteger;

@Configuration
public class BlockChainConfig {

    @Value("${SEPOLIA_NODE_ENDPOINT}")
    private String blockchainApiUrl;

    @Value("${STREAMING_AGGREGATION_CONTRACT_ADDRESS}")
    private String contractAddress;

    @Value("${OWNER_ADDRESS}")
    private String ownerAddress;

    @Value("${OWNER_PRIVATE_KEY}")
    private String privateKey;

    // EIP-155 체인 ID
    @Value("${CHAIN_ID:11155111}")
    private long chainId;

    @Bean
    public Web3j web3j() {
        return Web3j.build(new HttpService(blockchainApiUrl));
    }

    @Bean(name = "blockchainTransactionManager")
    public TransactionManager transactionManager(Web3j web3j) {
        // privateKey를 사용하여 Credentials 생성
        Credentials credentials = Credentials.create(privateKey);
        return new RawTransactionManager(web3j, credentials, chainId);
    }

    @Bean
    public ContractGasProvider contractGasProvider() {
        return new ContractGasProvider() {
            @Override
            public BigInteger getGasPrice() {
                return BigInteger.valueOf(1_000_000_000L); // 1 GWEI
            }

            @Override
            public BigInteger getGasLimit() {
                return BigInteger.valueOf(500_000L);
            }

            @Override
            public BigInteger getGasLimit(org.web3j.protocol.core.methods.request.Transaction transaction) {
                return BigInteger.valueOf(500_000L);
            }
        };
    }

    @Bean
    public StreamingAggregationContract streamingAggregationContract(
            Web3j web3j,
            TransactionManager transactionManager,
            ContractGasProvider contractGasProvider) {
        return StreamingAggregationContract.load(contractAddress, web3j, transactionManager, contractGasProvider);
    }
}
