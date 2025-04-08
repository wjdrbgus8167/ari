package com.ccc.ari.aggregation.infrastructure.adapter;

import com.ccc.ari.global.contract.StreamingAggregationContract;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.web3j.abi.EventEncoder;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.EthLog;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.utils.Numeric;

import java.io.IOException;
import java.math.BigInteger;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Component
public class StreamingAggregationContractEventListener {

    private final Web3j web3j;
    private final StreamingAggregationContract aggregationContract;
    private final Logger logger = LoggerFactory.getLogger(StreamingAggregationContractEventListener.class);

    @Autowired
    public StreamingAggregationContractEventListener(@Qualifier("streamingAggregationContractWeb3j") Web3j web3j,
                                                     StreamingAggregationContract aggregationContract) {
        this.web3j = web3j;
        this.aggregationContract = aggregationContract;
    }

    /**
     * 스마트 컨트랙트의 모든 RawAllTracksUpdated 이벤트를 조회합니다.
     *
     * @return 모든 RawAllTracksUpdated 이벤트 응답 목록
     */
    public List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> getAllRawAllTracksUpdatedEvents() {
        logger.info("RawAllTracksUpdated 이벤트 조회를 시작합니다.");
        try {
            logger.info("스마트 컨트랙트 주소: {}", aggregationContract.getContractAddress());

            // 이벤트 필터 생성 (모든 블록 범위)
            EthFilter filter = new EthFilter(
                    DefaultBlockParameterName.EARLIEST,
                    DefaultBlockParameterName.LATEST,
                    aggregationContract.getContractAddress()
            );
            logger.info("이벤트 필터 생성 완료: {}", filter);

            // 이벤트 토픽 인코딩
            filter.addSingleTopic(EventEncoder.encode(StreamingAggregationContract.RAWALLTRACKSUPDATED_EVENT));

            // 로그 조회
            EthLog ethLog = web3j.ethGetLogs(filter).send();
            List<EthLog.LogResult> logs = ethLog.getLogs();
            logger.info("이벤트 로그 조회 완료. 총 {}개의 로그를 가져왔습니다.", logs.size());

            // 이벤트 응답 리스트 생성
            List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> eventResponses = new ArrayList<>();

            // 각 로그에 대해 이벤트 처리
            for (EthLog.LogResult logResult : logs) {
                Log log = (Log) logResult.get();
                logger.info("이벤트 로그 처리 중: {}", log);

                // static 메서드 활용
                StreamingAggregationContract.RawAllTracksUpdatedEventResponse event =
                        StreamingAggregationContract.getRawAllTracksUpdatedEventFromLog(log);

                eventResponses.add(event);
                logger.info("이벤트 처리 완료: {}", event);
            }

            // 이벤트 응답 반환
            logger.info("RawAllTracksUpdated 이벤트 조회를 성공적으로 완료했습니다. 총 {}개의 이벤트 응답 반환.",
                    eventResponses.size());

            return eventResponses;

        } catch (IOException e) {
            // 네트워크 또는 이벤트 조회 중 예외 처리
            logger.error("모든 이벤트 조회 중 네트워크 오류 발생", e);
            return Collections.emptyList();
        }
    }

    /**
     * 특정 트랜잭션 해쉬로부터 RawAllTracksUpdated 이벤트 로그를 조회합니다.
     * 
     * 이 메소드는 주어진 트랜잭션 해쉬(txHash)를 기반으로 이벤트 로그를 조회하고,
     * 연관된 RawAllTracksUpdated 이벤트 응답 목록을 반환합니다.
     * 
     * @param txHash 이벤트의 트랜잭션
     * @return 트랜잭션에 해당하는 RawAllTracksUpdated 이벤트 응답 목록
     */
    public List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> getRawAllTracksUpdatedEventsByTxHash(
            String txHash) {
        logger.info("Transaction hash로부터 이벤트 조회를 시작합니다. TxHash: {}", txHash);
        try {
            // 트랜잭션 해시로 트랜잭션 영수증 조회
            TransactionReceipt receipt = web3j.ethGetTransactionReceipt(txHash).send().getTransactionReceipt().orElse(null);
            if (receipt == null) {
                logger.info("트랜잭션 receipt를 찾을 수 없습니다. TxHash: {}", txHash);
                return Collections.emptyList();
            }
    
            logger.info("트랜잭션 receipt 조회 성공. 블록 번호: {}", receipt.getBlockNumber());
    
            // 이벤트 응답 리스트 생성
            List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> eventResponses = new ArrayList<>();
    
            // 트랜잭션 로그 처리
            List<Log> logs = receipt.getLogs();
            for (Log log : logs) {
                StreamingAggregationContract.RawAllTracksUpdatedEventResponse event =
                        StreamingAggregationContract.getRawAllTracksUpdatedEventFromLog(log);
    
                eventResponses.add(event);
            }
    
            logger.info("Transaction hash로부터 이벤트 조회를 성공적으로 완료했습니다. TxHash: {}", txHash);
            return eventResponses;
    
        } catch (IOException e) {
            logger.error("이벤트 조회 중 네트워크 오류 발생", e);
            return Collections.emptyList();
        }
    }
    
    /**
     * 스마트 컨트랙트의 모든 RawArtistTracksUpdated 이벤트를 조회합니다.
     * 
     * 이 메소드는 스마트 컨트랙트에서 발생한 모든 RawArtistTracksUpdated 이벤트를 필터링하여
     * 이벤트 로그를 기반으로 응답 객체 목록을 반환합니다.
     * 
     * @return 모든 RawArtistTracksUpdated 이벤트 응답 목록
     */
    public List<StreamingAggregationContract.RawArtistTracksUpdatedEventResponse> getRawArtistTracksUpdatedEventsByArtistId(Integer artistId) {
        logger.info("RawArtistTracksUpdated 이벤트 조회를 시작합니다.");
        try {
            logger.info("스마트 컨트랙트 주소: {}", aggregationContract.getContractAddress());

            // 이벤트 필터 생성 (모든 블록 범위)
            EthFilter filter = new EthFilter(
                    DefaultBlockParameterName.EARLIEST,
                    DefaultBlockParameterName.LATEST,
                    aggregationContract.getContractAddress()
            );
            logger.info("이벤트 필터 생성 완료: {}", filter);

            // 이벤트 토픽 인코딩
            filter.addSingleTopic(EventEncoder.encode(StreamingAggregationContract.RAWARTISTTRACKSUPDATED_EVENT));

            // 첫 번째 indexed 파라미터(batchTimestamp)에 대해 필터링하지 않음
            filter.addOptionalTopics();

            // 두 번째 indexed 파라미터(artistId)에 대한 필터링
            String encodedArtistId = "0x" + Numeric.toHexStringNoPrefixZeroPadded(BigInteger.valueOf(artistId), 64);
            filter.addOptionalTopics(encodedArtistId);

            // 로그 조회
            EthLog ethLog = web3j.ethGetLogs(filter).send();
            List<EthLog.LogResult> logs = ethLog.getLogs();
            logger.info("이벤트 로그 조회 완료. 총 {}개의 로그를 가져왔습니다.", logs.size());

            // 이벤트 응답 리스트 생성
            List<StreamingAggregationContract.RawArtistTracksUpdatedEventResponse> eventResponses = new ArrayList<>();

            // 각 로그에 대해 이벤트 처리
            for (EthLog.LogResult logResult : logs) {
                Log log = (Log) logResult.get();
                logger.info("이벤트 로그 처리 중: {}", log);

                // static 메서드 활용
                StreamingAggregationContract.RawArtistTracksUpdatedEventResponse event =
                        StreamingAggregationContract.getRawArtistTracksUpdatedEventFromLog(log);

                eventResponses.add(event);
                logger.info("이벤트 처리 완료: {}", event);
            }

            // 이벤트 응답 반환
            logger.info("RawArtistTracksUpdated 이벤트 조회를 성공적으로 완료했습니다. 총 {}개의 이벤트 응답 반환.",
                    eventResponses.size());

            return eventResponses;

        } catch (IOException e) {
            // 네트워크 또는 이벤트 조회 중 예외 처리
            logger.error("모든 이벤트 조회 중 네트워크 오류 발생", e);
            return Collections.emptyList();
        }
    }
    
    
    /**
     * 시작 시간과 종료 시간을 기준으로 RawListenerTracksUpdated 이벤트를 조회합니다.
     * <p>
     * 이 메소드는 지정된 시간 범위 내에서 발생한 RawListenerTracksUpdated 이벤트를 필터링하여
     * 이벤트 로그 응답 객체 목록을 반환합니다.
     * 
     * @param startTime 조회할 이벤트의 시작 시간 (LocalDateTime)
     * @param endTime 조회할 이벤트의 종료 시간 (LocalDateTime)
     * @return 주어진 시간 범위 내 RawListenerTracksUpdated 이벤트 응답 목록
     */
    public List<StreamingAggregationContract.RawListenerTracksUpdatedEventResponse> getAllRawListenerTracksUpdatedEvents(
            LocalDateTime startTime, LocalDateTime endTime) {
        
        logger.info("RawListenerTracksUpdated 이벤트 조회를 시작합니다. 시작 시간: {}, 종료 시간: {}", startTime, endTime);

        try {
            // LocalDateTime을 Unix timestamp (초 단위)로 변환
            BigInteger startTimestamp = BigInteger.valueOf(startTime.toEpochSecond(ZoneOffset.UTC));
            BigInteger endTimestamp = BigInteger.valueOf(endTime.toEpochSecond(ZoneOffset.UTC));

            EthFilter filter = new EthFilter(
                    DefaultBlockParameterName.EARLIEST,
                    DefaultBlockParameterName.LATEST,
                    aggregationContract.getContractAddress()
            );

            // 이벤트 시그니처 추가
            filter.addSingleTopic(EventEncoder.encode(StreamingAggregationContract.RAWLISTENERTRACKSUPDATED_EVENT));

            // 로그 조회
            EthLog ethLog = web3j.ethGetLogs(filter).send();
            List<EthLog.LogResult> logs = ethLog.getLogs();
            logger.info("이벤트 로그 조회 완료. 총 {}개의 로그를 가져왔습니다.", logs.size());

            // 이벤트 응답 리스트 생성
            List<StreamingAggregationContract.RawListenerTracksUpdatedEventResponse> eventResponses = new ArrayList<>();

            // 각 로그를 처리하면서 timestamp 기준으로 필터링
            for (EthLog.LogResult logResult : logs) {
                Log log = (Log) logResult.get();
                StreamingAggregationContract.RawListenerTracksUpdatedEventResponse event =
                        StreamingAggregationContract.getRawListenerTracksUpdatedEventFromLog(log);

                // batchTimestamp가 시작 시간과 종료 시간 사이에 있는지 확인
                if (event.batchTimestamp.compareTo(startTimestamp) >= 0 &&
                        event.batchTimestamp.compareTo(endTimestamp) <= 0) {
                    eventResponses.add(event);
                    logger.info("이벤트 처리 완료: {}", event);
                }
            }

            logger.info("지정된 시간 범위 내 이벤트 필터링 완료. 총 {}개의 이벤트 응답 반환.", eventResponses.size());
            return eventResponses;

        } catch (IOException e) {
            logger.error("이벤트 조회 중 네트워크 오류 발생", e);
            return Collections.emptyList();
        }
    }
}
