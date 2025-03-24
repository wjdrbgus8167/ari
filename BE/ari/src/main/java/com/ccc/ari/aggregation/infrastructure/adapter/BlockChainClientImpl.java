package com.ccc.ari.aggregation.infrastructure.adapter;

import com.ccc.ari.aggregation.domain.client.BlockChainClient;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.RemoteCall;
import org.web3j.protocol.core.methods.request.Transaction;
import org.web3j.protocol.core.methods.response.EthBlockNumber;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.ClientTransactionManager;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;
import org.web3j.tx.gas.DefaultGasProvider;

import java.math.BigInteger;
import java.util.Optional;

/**
 * BlockchainClientImpl는 블록체인 네트워크(Infura)를 통해 스마트 컨트랙트에 데이터를 커밋하는 기능을 제공합니다.
 * 이 구현체는 StreamingAggregationContract의 commitRawAllTracks 등의 함수를 호출하여,
 * 입력받은 CID를 온체인에 기록하고, 그 결과로 발생한 트랜잭션 해시를 반환합니다.
 */
@Component
public class BlockChainClientImpl implements BlockChainClient {

    private static final Logger log = LoggerFactory.getLogger(BlockChainClientImpl.class);

    private final Web3j web3j;
    //private final TransactionManager transactionManager;
    private final ContractGasProvider gasProvider;
    private final StreamingAggregationContract aggregationContract;

    /**
     * 생성자
     *
     * @param blockchainApiUrl    블록체인 API URL (Infura 호스팅 엔드포인트)
     * @param contractAddress     배포된 StreamingAggregationContract의 주소
     * @param ownerAddress        스마트 컨트랙트 호출에 사용할 계정 주소 (MetaMask 지갑 주소)
     *
     */
    public BlockChainClientImpl(
            @Value("${AMOY_NODE_ENDPOINT}") String blockchainApiUrl,
            @Value("${STREAMING_AGGREGATION_CONTRACT_ADDRESS}") String contractAddress,
            @Value("${OWNER_ADDRESS}") String ownerAddress,
            @Value("${OWNER_PRIVATE_KEY}") String privateKey) {

        // Web3j 인스턴스 생성 (Infura 엔드포인트 등)
        this.web3j = Web3j.build(new HttpService(blockchainApiUrl));
        // 호스팅 노드 엔드포인트 연결 확인
        try {
            EthBlockNumber blockNumber = web3j.ethBlockNumber().send();
            log.info("블록체인에 연결되었습니다. 현재 블록: {}", blockNumber.getBlockNumber());
        } catch (Exception e) {
            log.error("{}에 있는 블록체인 노드 연결 실패", blockchainApiUrl, e);
            throw new RuntimeException("블록체인 노드에 연결할 수 없습니다", e);
        }

        // 커스텀 가스 프로바이더 설정
        this.gasProvider = new ContractGasProvider() {
            @Override
            public BigInteger getGasPrice() {
                return BigInteger.valueOf(50_000_000_000L); // 50 GWEI
            }

            @Override
            public BigInteger getGasLimit(Transaction transaction) {
                return BigInteger.valueOf(300_000L);
            }

            @Override
            public BigInteger getGasLimit() {
                return BigInteger.valueOf(300_000L);
            }
        };;

        // privateKey를 사용하여 Credentials 생성
        Credentials credentials = Credentials.create(privateKey);

        // EIP-155 지원을 위한 chainId 설정
        long chainId = 80002;

        // 배포된 스마트 컨트랙트의 Wrapper 클래스를 로드합니다.
        this.aggregationContract = StreamingAggregationContract.load(
                contractAddress,
                web3j,
                new RawTransactionManager(
                        web3j,
                        credentials,
                        chainId
                ),
                gasProvider
        );
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
            log.info("전체 트랙 데이터를 블록체인에 커밋합니다. CID: {}", cid);

            // 트랜잭션 해시 먼저 가져오기
            String txHash = aggregationContract.commitRawAllTracks(cid).send().getTransactionHash();
            log.info("트랜잭션이 제출되었습니다. 해시: {}", txHash);

            // 트랜잭션 상태 주기적으로 확인
            int attempts = 0;
            while (attempts < 30) { // 5분 동안 확인 (30 * 10초)
                try {
                    Optional<TransactionReceipt> receipt =
                            web3j.ethGetTransactionReceipt(txHash).send().getTransactionReceipt();
                    if (receipt.isPresent()) {
                        log.info("전체 트랙 데이터 커밋 성공. 트랜잭션 해시: {}", txHash);
                        return txHash;
                    }
                } catch (Exception e) {
                    log.warn("영수증 확인 중 오류, 재시도 예정: {}", e.getMessage());
                }

                Thread.sleep(10000); // 확인 사이에 10초 대기
                attempts++;
            }

            log.warn("트랜잭션이 아직 처리 중일 수 있습니다. 해시: {}", txHash);
            return txHash;
        } catch (Exception e) {
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
