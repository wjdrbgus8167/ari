package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.aggregation.infrastructure.adapter.BlockChainEventListener;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StreamingLogQueryService {

    private final IpfsClient ipfsClient;
    private final BlockChainEventListener blockChainEventListener;
    
    private static final Logger logger = LoggerFactory.getLogger(StreamingLogQueryService.class);

    /**
     * 특정 트랙의 전체 스트리밍 로그를 조회합니다.
     * 블록체인 이벤트로부터 IPFS에 저장된 데이터를 가져와 필터링합니다.
     *
     * @param trackId 조회할 트랙 ID
     * @return 특정 트랙의 타임스탬프 기준 정렬된 스트리밍 로그 목록
     */
    public List<StreamingLog> findStreamingLogByTrackId(Integer trackId) {
        // 블록체인 이벤트 구독 및 IPFS 데이터 처리를 위한 리스트 준비
        logger.info("findStreamingLogByTrackId 메서드 호출 - trackId: {}", trackId);

        // 블록체인으로부터 이벤트 로그 조회
        List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> events =
                blockChainEventListener.getAllRawAllTracksUpdatedEvents();

        logger.info("블록체인으로부터 {}개의 이벤트가 조회되었습니다.", events.size());
        logger.info("IPFS에서 데이터를 조회하고 처리 중입니다.");

        List<StreamingLog> allStreamingLog;

        allStreamingLog = events.stream()
                // 각 이벤트의 CID를 사용하여 IPFS에서 데이터 조회
                .map(event -> {
                    String jsonData = ipfsClient.get(event.cid);
                    return AggregatedData.fromJson(jsonData);
                })
                // 각 AggregatedData의 스트리밍 로그를 평탄화
                .flatMap(aggregatedData -> aggregatedData.getStreamingLogs().stream())
                // 지정된 trackId와 일치하는 로그만 필터링
                .peek(log -> logger.debug("streamingLog 확인: {}", log))
                .filter(log -> log.getTrackId().equals(trackId))
                // 타임스탬프 기준 정렬
                .sorted(Comparator.comparing(StreamingLog::getTimestamp))
                        // 리스트로 수집
                        .collect(Collectors.toList());

        logger.info("총 {}개의 스트리밍 로그가 정렬 및 필터링되었습니다.", allStreamingLog.size());

        logger.info("findStreamingLogByTrackId 처리 완료 - trackId: {}", trackId);

        // TODO: 이후에는 The Graph로 마이그레이션

        return allStreamingLog;
    }
}
