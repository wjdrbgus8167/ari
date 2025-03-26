package com.ccc.ari.aggregation.infrastructure.adapter;

import com.ccc.ari.aggregation.domain.client.BlockChainClient;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.TransactionReceipt;

import java.util.List;
import java.util.Optional;

/**
 * BlockchainClientImpl는 블록체인 네트워크(Infura)를 통해 스마트 컨트랙트에 데이터를 커밋하는 기능을 제공합니다.
 * 이 구현체는 StreamingAggregationContract의 commitRawAllTracks 등의 함수를 호출하여,
 * 입력받은 CID를 온체인에 기록하고, 그 결과로 발생한 트랜잭션 해시를 반환합니다.
 */
@Component
@RequiredArgsConstructor
public class BlockChainClientImpl implements BlockChainClient {

    private static final Logger log = LoggerFactory.getLogger(BlockChainClientImpl.class);

    private final Web3j web3j;
    private final StreamingAggregationContract aggregationContract;

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
                    Optional<TransactionReceipt> receiptOptional =
                            web3j.ethGetTransactionReceipt(txHash).send().getTransactionReceipt();
                    if (receiptOptional.isPresent()) {
                        TransactionReceipt receipt = receiptOptional.get();
                        log.info("전체 트랙 데이터 커밋 성공. 트랜잭션 해시: {}", txHash);

                        // 이벤트 파싱 메소드를 사용하여 이벤트 로그 추출
                        List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> events =
                                StreamingAggregationContract.getRawAllTracksUpdatedEvents(receipt);

                        for (StreamingAggregationContract.RawAllTracksUpdatedEventResponse event : events) {
                            log.info("이벤트 발생 - batchTimestamp: {}, cid: {}", event.batchTimestamp, event.cid);
                        }

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
