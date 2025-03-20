package com.ccc.ari.aggregation.infrastructure.adapter;

import com.ccc.ari.aggregation.domain.client.BlockChainClient;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.RemoteCall;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.ClientTransactionManager;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;
import org.web3j.tx.gas.DefaultGasProvider;

/**
 * BlockchainClientImpl는 블록체인 네트워크(Infura)를 통해 스마트 컨트랙트에 데이터를 커밋하는 기능을 제공합니다.
 * 이 구현체는 StreamingAggregationContract의 commitRawAllTracks 등의 함수를 호출하여,
 * 입력받은 CID를 온체인에 기록하고, 그 결과로 발생한 트랜잭션 해시를 반환합니다.
 */
@Component
public class BlockChainClientImpl implements BlockChainClient {

    private static final Logger log = LoggerFactory.getLogger(BlockChainClientImpl.class);

    private final Web3j web3j;
    private final TransactionManager transactionManager;
    private final ContractGasProvider gasProvider;
    private final StreamingAggregationContract aggregationContract;

    /**
     * 생성자
     *
     * @param blockchainApiUrl    블록체인 API URL (Infura 호스팅 엔드포인트)
     * @param contractAddress     배포된 StreamingAggregationContract의 주소
     * @param ownerAddress        스마트 컨트랙트 호출에 사용할 계정 주소 (MetaMask 지갑 주소)
     */
    public BlockChainClientImpl(
            @Value("${AMOY_NODE_ENDPOINT}") String blockchainApiUrl,
            @Value("${STREAMING_AGGREGATION_CONTRACT_ADDRESS}") String contractAddress,
            @Value("${OWNER_ADDRESS}") String ownerAddress) {
        // Web3j 인스턴스 생성 (Infura 엔드포인트 등)
        this.web3j = Web3j.build(new HttpService(blockchainApiUrl));
        // 해당 계정(소유자 주소)로 트랜잭션 서명을 수행할 TransactionManager 설정
        this.transactionManager = new ClientTransactionManager(web3j, ownerAddress);
        // 가스 프로바이더 설정 (필요 시 커스텀 설정 가능)
        this.gasProvider = new DefaultGasProvider();
        // 배포된 스마트 컨트랙트의 Wrapper 클래스를 로드합니다.
        this.aggregationContract = StreamingAggregationContract.load(contractAddress, web3j, transactionManager, gasProvider);
    }

    /**
     * 전체 트랙에 대한 스트리밍 데이터의 CID를 스마트 컨트랙트에 기록하고,
     * 그 결과로 발생한 트랜잭션 해시를 반환합니다.
     *
     * @param cid IPFS에 저장된 AggregatedData의 CID
     * @return 트랜잭션 해시 (String)
     */
    @Override
    public String commitRawAllTracks(String cid) {
        try {
            // 로그: 커밋 시작
            log.info("전체 트랙 데이터를 블록체인에 커밋합니다. CID: {}", cid);

            // 1. commitRawAllTracks 함수 호출: 전체 스트리밍 집계 데이터를 온체인에 기록
            RemoteCall<TransactionReceipt> remoteCall = aggregationContract.commitRawAllTracks(cid);
            TransactionReceipt receipt = remoteCall.send();

            // 로그: 커밋 성공
            log.info("전체 트랙 데이터 커밋 성공. 트랜잭션 해시: {}", receipt.getTransactionHash());

            // 2. 트랜잭션 해시 반환
            return receipt.getTransactionHash();
        } catch (Exception e) {
            // 로그: 커밋 실패
            log.error("전체 트랙 데이터 커밋에 실패했습니다. CID: {}", cid, e);
            throw new RuntimeException("블록체인 커밋에 실패했습니다.", e);
        }
    }

    // TODO: 추후에 구현하도록 하겠습니다.
    @Override
    public String commitRawGenreTracks(byte[] genreId, String cid) {
        return "";
    }

    @Override
    public String commitRawArtistTracks(byte[] artistId, String cid) {
        return "";
    }

    @Override
    public String commitRawListenerTracks(byte[] listenerId, String cid) {
        return "";
    }
}
