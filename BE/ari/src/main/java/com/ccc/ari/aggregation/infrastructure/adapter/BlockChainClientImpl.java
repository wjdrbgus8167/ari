package com.ccc.ari.aggregation.infrastructure.adapter;

import com.ccc.ari.aggregation.domain.client.BlockChainClient;
import com.ccc.ari.aggregation.util.ByteConverter;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
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
public class BlockChainClientImpl implements BlockChainClient {

    private static final Logger log = LoggerFactory.getLogger(BlockChainClientImpl.class);

    private final Web3j web3j;
    private final StreamingAggregationContract aggregationContract;

    @Autowired
    public BlockChainClientImpl(@Qualifier("streamingAggregationContractWeb3j") Web3j web3j,
                                StreamingAggregationContract aggregationContract) {
        this.web3j = web3j;
        this.aggregationContract = aggregationContract;
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

    /**
     * 특정 장르에 대한 스트리밍 데이터의 CID를 스마트 컨트랙트에 기록하고,
     * 그 결과로 발생한 트랜잭션 해시를 반환합니다.
     *
     * @param genreId 조회할 장르 ID
     * @param cid IPFS에 저장된 AggregatedData의 CID
     * @return 트랜잭션 해시 (String)
     */
    @Override
    public String commitRawGenreTracks(Integer genreId, String cid) {
        byte[] genreIdBytes = ByteConverter.intTo32Bytes(genreId);
        try {
            log.info("장르 트랙 데이터를 블록체인에 커밋합니다. genreId: {}, CID: {}", genreId, cid);

            // 트랜잭션 해시 먼저 가져오기
            String txHash = aggregationContract.commitRawGenreTracks(genreIdBytes, cid).send().getTransactionHash();
            log.info("트랜잭션이 제출되었습니다. 해시: {}", txHash);

            // 트랜잭션 상태 주기적으로 확인
            int attempts = 0;
            while (attempts < 30) { // 5분 동안 확인 (30 * 10초)
                try {
                    Optional<TransactionReceipt> receiptOptional =
                            web3j.ethGetTransactionReceipt(txHash).send().getTransactionReceipt();
                    if (receiptOptional.isPresent()) {
                        TransactionReceipt receipt = receiptOptional.get();
                        log.info("장르 트랙 데이터 커밋 성공. 트랜잭션 해시: {}", txHash);

                        // 이벤트 파싱 메소드를 사용하여 이벤트 로그 추출
                        List<StreamingAggregationContract.RawGenreTracksUpdatedEventResponse> events =
                                StreamingAggregationContract.getRawGenreTracksUpdatedEvents(receipt);

                        for (StreamingAggregationContract.RawGenreTracksUpdatedEventResponse event : events) {
                            log.info("이벤트 발생 - batchTimestamp: {}, genreId: {}, cid: {}",
                                    event.batchTimestamp, ByteConverter.bytes32ToInt(event.genreId), event.cid);
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
            log.error("장르 트랙 데이터 커밋에 실패했습니다. genreId: {}, CID: {}",
                    ByteConverter.bytes32ToInt(genreIdBytes), cid, e);
            throw new RuntimeException("블록체인 커밋에 실패했습니다.", e);
        }
    }

    /**
     * 특정 장르에 대한 스트리밍 데이터의 CID를 스마트 컨트랙트에 기록하고,
     * 그 결과로 발생한 트랜잭션 해시를 반환합니다.
     *
     * @param artistId 조회할 장르 ID
     * @param cid IPFS에 저장된 AggregatedData의 CID
     * @return 트랜잭션 해시 (String)
     */
    @Override
    public String commitRawArtistTracks(Integer artistId, String cid) {
        byte[] artistIdBytes = ByteConverter.intTo32Bytes(artistId);
        try {
            log.info("아티스트 트랙 데이터를 블록체인에 커밋합니다. artistId: {}, CID: {}", artistId, cid);

            // 트랜잭션 해시 먼저 가져오기
            String txHash = aggregationContract.commitRawArtistTracks(artistIdBytes, cid).send().getTransactionHash();
            log.info("트랜잭션이 제출되었습니다. 해시: {}", txHash);

            // 트랜잭션 상태 주기적으로 확인
            int attempts = 0;
            while (attempts < 30) { // 5분 동안 확인 (30 * 10초)
                try {
                    Optional<TransactionReceipt> receiptOptional =
                            web3j.ethGetTransactionReceipt(txHash).send().getTransactionReceipt();
                    if (receiptOptional.isPresent()) {
                        TransactionReceipt receipt = receiptOptional.get();
                        log.info("아티스트 트랙 데이터 커밋 성공. 트랜잭션 해시: {}", txHash);

                        // 이벤트 파싱 메소드를 사용하여 이벤트 로그 추출
                        List<StreamingAggregationContract.RawArtistTracksUpdatedEventResponse> events =
                                StreamingAggregationContract.getRawArtistTracksUpdatedEvents(receipt);

                        for (StreamingAggregationContract.RawArtistTracksUpdatedEventResponse event : events) {
                            log.info("이벤트 발생 - batchTimestamp: {}, artistId: {}, cid: {}",
                                    event.batchTimestamp, ByteConverter.bytes32ToInt(event.artistId), event.cid);
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
            log.error("아티스트 트랙 데이터 커밋에 실패했습니다. artistId: {}, CID: {}",
                    ByteConverter.bytes32ToInt(artistIdBytes), cid, e);
            throw new RuntimeException("블록체인 커밋에 실패했습니다.", e);
        }
    }

    @Override
    public String commitRawListenerTracks(Integer listenerId, String cid) {
        byte[] listenerIdBytes = ByteConverter.intTo32Bytes(listenerId);
        try {
            log.info("리스너 트랙 데이터를 블록체인에 커밋합니다. listenerId: {}, CID: {}", listenerId, cid);

            // 트랜잭션 해시 먼저 가져오기
            String txHash = aggregationContract.commitRawListenerTracks(listenerIdBytes, cid).send().getTransactionHash();
            log.info("트랜잭션이 제출되었습니다. 해시: {}", txHash);

            // 트랜잭션 상태 주기적으로 확인
            int attempts = 0;
            while (attempts < 30) { // 5분 동안 확인 (30 * 10초)
                try {
                    Optional<TransactionReceipt> receiptOptional =
                            web3j.ethGetTransactionReceipt(txHash).send().getTransactionReceipt();
                    if (receiptOptional.isPresent()) {
                        TransactionReceipt receipt = receiptOptional.get();
                        log.info("리스너 트랙 데이터 커밋 성공. 트랜잭션 해시: {}", txHash);

                        // 이벤트 파싱 메소드를 사용하여 이벤트 로그 추출
                        List<StreamingAggregationContract.RawListenerTracksUpdatedEventResponse> events =
                                StreamingAggregationContract.getRawListenerTracksUpdatedEvents(receipt);

                        for (StreamingAggregationContract.RawListenerTracksUpdatedEventResponse event : events) {
                            log.info("이벤트 발생 - batchTimestamp: {}, listenerId: {}, cid: {}",
                                    event.batchTimestamp, ByteConverter.bytes32ToInt(event.listenerId), event.cid);
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
            log.error("리스너 트랙 데이터 커밋에 실패했습니다. listenerId: {}, CID: {}",
                    ByteConverter.bytes32ToInt(listenerIdBytes), cid, e);
            throw new RuntimeException("블록체인 커밋에 실패했습니다.", e);
        }
    }
}
