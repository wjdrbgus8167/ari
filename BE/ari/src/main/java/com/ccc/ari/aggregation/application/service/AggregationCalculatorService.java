package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.aggregation.event.OnChainCommitCompletedEvent;
import com.ccc.ari.aggregation.infrastructure.adapter.StreamingAggregationContractEventListener;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import com.ccc.ari.global.event.AllAggregationCalculatedEvent;
import com.ccc.ari.global.event.GenreAggregationCalculatedEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AggregationCalculatorService {

    private final ApplicationEventPublisher eventPublisher;
    private final StreamingAggregationContractEventListener streamingAggregationContractEventListener;
    private final IpfsClient ipfsClient;
    private final Logger logger = LoggerFactory.getLogger(AggregationCalculatorService.class);

    /**
     * 온체인 커밋 완료 이벤트를 처리하는 리스너 메소드
     * 전체 집계 데이터를 불러온 후 전체와 장르별로 카운팅해 이벤트를 발행합니다.
     *
     * @param event OnChainCommitCompletedEvent (온체인 커밋 완료 이벤트)
     */
    @EventListener
    public void handleOnChainCommitCompleted(OnChainCommitCompletedEvent event) {
        String txHash = event.getTxHash();
        try {
            logger.info("트랙의 차트 데이터 집계를 처리합니다. txHash: {}", txHash);
            List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> events =
                    streamingAggregationContractEventListener.getRawAllTracksUpdatedEventsByTxHash(txHash);
            if (events.isEmpty()) {
                logger.info("RawAllTracksUpdated가 없습니다. txHash: {}", txHash);
                return;
            }
            for (StreamingAggregationContract.RawAllTracksUpdatedEventResponse eventResponse : events) {
                logger.info("RawAllTracksUpdatedEvent를 발견했습니다. batchTimestamp={}, cid={}",
                        eventResponse.batchTimestamp, eventResponse.cid);
                logger.info("IPFS 데이터 조회 시작. CID: {}", eventResponse.cid);
                String jsonData = ipfsClient.get(eventResponse.cid);
                logger.info("IPFS 데이터 조회 성공. 응답 크기: {}", jsonData.length());
                AggregatedData aggregatedData = AggregatedData.fromJson(jsonData);
                List<StreamingLog> streamingLogs = aggregatedData.getStreamingLogs();

                // 1. 전체 스트리밍 카운팅
                // StreamingLogs를 trackId로 그룹화하여 카운트하고 로깅
                Map<Integer, Long> allTrackCounts = streamingLogs.stream()
                        .collect(Collectors.groupingBy(
                                StreamingLog::getTrackId,
                                Collectors.counting()
                        ));

                allTrackCounts.forEach((trackId, count) ->
                        logger.info("집계된 StreamingLog: trackId={}, count={}", trackId, count));

                // AllAggregationCalculatedEvent 발행
                eventPublisher.publishEvent(new AllAggregationCalculatedEvent(allTrackCounts));
                logger.info("AllAggregationCalculatedEvent가 성공적으로 발행되었습니다.");

                // 2. 장르별 스트리밍 카운팅
                // StreamingLogs를 genreId 별로 그룹화한 뒤 trackId로 그룹화하여 카운팅
                Map<Integer, Map<Integer, Long>> genreTrackCount = streamingLogs.stream()
                        .collect(Collectors.groupingBy(
                                StreamingLog::getGenreId,
                                Collectors.groupingBy(
                                        StreamingLog::getTrackId,
                                        Collectors.counting()
                                )
                        ));

                genreTrackCount.forEach((genreId, trackCounts) -> {
                    trackCounts.forEach((trackId, count) ->
                            logger.info("집계된 StreamingLog: genreId={}, trackId={}, count={}", genreId, trackId, count));
                });

                // GenreAggregationCalculatedEvent 발행
                eventPublisher.publishEvent(new GenreAggregationCalculatedEvent(genreTrackCount));
                logger.info("GenreAggregationCalculatedEvent 성공적으로 발행되었습니다.");
            }
        } catch (Exception e) {
            logger.error("전체 트랙 데이터 집계를 처리하는 중 오류가 발생했습니다. txHash: {}", txHash, e);
        }
    }
}
