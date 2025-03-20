package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.domain.client.BlockChainClient;
import com.ccc.ari.aggregation.domain.client.IpfsClient;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;

@Service
public class StreamingLogQueryService {

    private final BlockChainClient blockChainClient;
    private final IpfsClient ipfsClient;
    private final Web3j web3j;

    public StreamingLogQueryService(BlockChainClient blockChainClient, IpfsClient ipfsClient,
                                    @Value("${AMOY_NODE_ENDPOINT}") String blockchainApiUrl) {
        this.blockChainClient = blockChainClient;
        this.ipfsClient = ipfsClient;
        this.web3j = Web3j.build(new HttpService(blockchainApiUrl));
    }

    // TODO: Flowable API를 사용해 이벤트 로그 조회
    // TODO: 이후에는 The Graph로 마이그레이션
}
