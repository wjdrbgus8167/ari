package com.ccc.ari.settlement.infrastructure.blockchain.adapter;

import com.ccc.ari.global.contract.StreamingAggregationContract;
import com.ccc.ari.global.contract.SubscriptionContract;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.TypeEncoder;
import org.web3j.abi.datatypes.Type;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.EthLog;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.utils.Numeric;

import java.io.IOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Component
public class SettlementExecutedEventListener {

    private final Web3j web3j;
    private final SubscriptionContract subscriptionContract;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    public SettlementExecutedEventListener(@Qualifier("settlementContractWeb3j") Web3j web3j,
                                           SubscriptionContract subscriptionContract) {
        this.web3j = web3j;
        this.subscriptionContract = subscriptionContract;
    }

    /**
     * 특정 아티스트의 모든 정기 구독 사이클에 대한 정산 내역들을 조회합니다.
     */
    public List<SubscriptionContract.SettlementExecutedRegularEventResponse> getAllRegularSettlementExecutedEvents(BigInteger artistId) {
        logger.info("SettlementExecutedRegularEvent 이벤트 조회를 시작합니다.");
        try {
            // 이벤트 필터 생성 (모든 블록 범위)
            EthFilter filter = new EthFilter(
                    DefaultBlockParameterName.EARLIEST,
                    DefaultBlockParameterName.LATEST,
                    subscriptionContract.getContractAddress()
            );
            logger.info("이벤트 필터 생성 완료: {}", filter);

            // 이벤트 토픽 인코딩
            filter.addSingleTopic(EventEncoder.encode(SubscriptionContract.SETTLEMENTEXECUTEDREGULAR_EVENT));
            // 아티스트 ID에 대한 토픽 추가
            filter.addOptionalTopics(null, // userId는 필터링하지 않음
                                     "0x" + Numeric.toHexStringNoPrefixZeroPadded(artistId, 64), // Uint256 타입으로 인코딩
                                     null // cycleId는 필터링하지 않음
            );
            
            // 로그 조회
            EthLog ethLog = web3j.ethGetLogs(filter).send();
            List<EthLog.LogResult> logs = ethLog.getLogs();
            logger.info("이벤트 로그 조회 완료. 총 {}개의 로그를 가져왔습니다.", logs.size());

            // 이벤트 응답 리스트 생성
            List<SubscriptionContract.SettlementExecutedRegularEventResponse> eventResponses = new ArrayList<>();

            // 각 로그에 대해 이벤트 처리
            for (EthLog.LogResult logResult : logs) {
                Log log = (Log) logResult.get();
                logger.info("이벤트 로그 처리 중: {}", log);

                // static 메서드 활용
                SubscriptionContract.SettlementExecutedRegularEventResponse event =
                        SubscriptionContract.getSettlementExecutedRegularEventFromLog(log);

                eventResponses.add(event);
                logger.info("이벤트 처리 완료: {}", event);
            }

            // 이벤트 응답 반환
            logger.info("SettlementExecutedRegularEvent 이벤트 조회를 성공적으로 완료했습니다. 총 {}개의 이벤트 응답 반환.",
                    eventResponses.size());

            return eventResponses;
            
        } catch (IOException e) {
            logger.error("아티스트(ID: {})의 모든 정기 구독 사이클 정산 이벤트 조회 중 네트워크 오류 발생",
                    artistId.intValue(), e);
            return Collections.emptyList();
        }
    }
    
    /**
     * 특정 아티스트의 모든 아티스트 구독 사이클에 대한 정산 내역들을 조회합니다.
     */
    public List<SubscriptionContract.SettlementExecutedArtistEventResponse> getAllArtistSettlementExecutedEvents(BigInteger artistId) {
        logger.info("SettlementExecutedArtistEvent 이벤트 조회를 시작합니다.");
        try {
            // 이벤트 필터 생성 (모든 블록 범위)
            EthFilter filter = new EthFilter(
                    DefaultBlockParameterName.EARLIEST,
                    DefaultBlockParameterName.LATEST,
                    subscriptionContract.getContractAddress()
            );
            logger.info("이벤트 필터 생성 완료: {}", filter);
    
            // 이벤트 토픽 인코딩
            filter.addSingleTopic(EventEncoder.encode(SubscriptionContract.SETTLEMENTEXECUTEDARTIST_EVENT));
            // 아티스트 ID에 대한 토픽 추가
            filter.addOptionalTopics(null, // userId는 필터링하지 않음
                                     "0x" + Numeric.toHexStringNoPrefixZeroPadded(artistId, 64), // Uint256 타입으로 인코딩
                                     null // cycleId는 필터링하지 않음
            );
    
            // 로그 조회
            EthLog ethLog = web3j.ethGetLogs(filter).send();
            List<EthLog.LogResult> logs = ethLog.getLogs();
            logger.info("이벤트 로그 조회 완료. 총 {}개의 로그를 가져왔습니다.", logs.size());
    
            // 이벤트 응답 리스트 생성
            List<SubscriptionContract.SettlementExecutedArtistEventResponse> eventResponses = new ArrayList<>();
    
            // 각 로그에 대해 이벤트 처리
            for (EthLog.LogResult logResult : logs) {
                Log log = (Log) logResult.get();
                logger.info("이벤트 로그 처리 중: {}", log);
    
                // static 메서드 활용
                SubscriptionContract.SettlementExecutedArtistEventResponse event =
                        SubscriptionContract.getSettlementExecutedArtistEventFromLog(log);
    
                eventResponses.add(event);
                logger.info("이벤트 처리 완료: {}", event);
            }
    
            // 이벤트 응답 반환
            logger.info("SettlementExecutedRegularArtist 이벤트 조회를 성공적으로 완료했습니다. 총 {}개의 이벤트 응답 반환.",
                    eventResponses.size());
    
            return eventResponses;

        } catch (IOException e) {
            logger.error("아티스트(ID: {})의 모든 아티스트 구독 사이클 정산 이벤트 조회 중 네트워크 오류 발생",
                    artistId.intValue(), e);
            return Collections.emptyList();
        }
    }
}
