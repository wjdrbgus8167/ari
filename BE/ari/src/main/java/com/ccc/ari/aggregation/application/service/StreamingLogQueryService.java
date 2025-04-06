package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.aggregation.infrastructure.adapter.StreamingAggregationContractEventListener;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StreamingLogQueryService {

    private final IpfsClient ipfsClient;
    private final StreamingAggregationContractEventListener streamingAggregationContractEventListener;

    private static final Logger logger = LoggerFactory.getLogger(StreamingLogQueryService.class);

    /**
     * 특정 트랙의 전체 스트리밍 로그를 조회합니다.
     * 블록체인 이벤트로부터 IPFS에 저장된 데이터를 가져와 필터링합니다.
     *
     * @param trackId 조회할 트랙 ID
     * @return 특정 트랙의 타임스탬프 기준 정렬된 스트리밍 로그 목록
     */
    public List<StreamingLog> findStreamingLogByTrackId(Integer trackId) {
        logger.info("findStreamingLogByTrackId 메서드 호출 - trackId: {}", trackId);

        // 블록체인으로부터 이벤트 로그 조회
        List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> events =
                streamingAggregationContractEventListener.getAllRawAllTracksUpdatedEvents();
        logger.info("블록체인으로부터 {}개의 이벤트가 조회되었습니다.", events.size());
        logger.info("IPFS에서 데이터를 조회하고 처리 중입니다.");

        // 각 이벤트별로 비동기적으로 IPFS 데이터를 조회
        List<CompletableFuture<List<StreamingLog>>> futureStreamingLogs = events.stream()
                .map(event -> CompletableFuture.supplyAsync(() -> {
                    logger.info("IPFS 데이터 조회 시작. CID: {}", event.cid);
                    String jsonData = ipfsClient.get(event.cid);
                    logger.info("IPFS 데이터 조회 성공. 응답 크기: {}", jsonData.length());
                    AggregatedData aggregatedData = AggregatedData.fromJson(jsonData);
                    return aggregatedData.getStreamingLogs();
                }))
                .collect(Collectors.toList());

        // 모든 CompletableFuture가 완료될 때까지 대기하고, 결과를 평탄화
        List<StreamingLog> allStreamingLogs = futureStreamingLogs.stream()
                .map(CompletableFuture::join)
                .flatMap(List::stream)
                .peek(log -> logger.debug("streamingLog 확인: {}", log))
                // 조회할 trackId와 일치하는 로그만 필터링
                .filter(log -> log.getTrackId().equals(trackId))
                // 타임스탬프 기준 정렬
                .sorted(Comparator.comparing(StreamingLog::getTimestamp))
                .collect(Collectors.toList());

        logger.info("총 {}개의 스트리밍 로그가 정렬 및 필터링되었습니다.", allStreamingLogs.size());
        logger.info("findStreamingLogByTrackId 처리 완료 - trackId: {}", trackId);

        // TODO: 이후에는 The Graph로 마이그레이션

        return allStreamingLogs;
    }

    /**
     * 특정 아티스트가 발매한 트랙들의 스트리밍 로그를 조회합니다.
     * 
     * @param artistId 조회할 아티스트 ID
     * @return 해당 아티스트가 발매한 트랙들의 스트리밍 로그 리스트
     */
    public List<StreamingLog> findStreamingLogByArtistId(Integer artistId) {
        logger.info("findStreamingLogByArtistId 메서드 호출 - artistId: {}", artistId);

        List<StreamingAggregationContract.RawArtistTracksUpdatedEventResponse> events =
                streamingAggregationContractEventListener.getAllRawArtistTracksUpdatedEvents();
        logger.info("블록체인으로부터 {}개의 이벤트가 조회되었습니다.", events.size());
        logger.info("IPFS에서 데이터를 조회하고 처리 중입니다.");

        // 각 이벤트별로 비동기적으로 IPFS 데이터를 조회
        List<CompletableFuture<List<StreamingLog>>> futureStreamingLogs = events.stream()
                .map(event -> CompletableFuture.supplyAsync(() -> {
                    logger.info("IPFS 데이터 조회 시작. CID: {}", event.cid);
                    String jsonData = ipfsClient.get(event.cid);
                    logger.info("IPFS 데이터 조회 성공. 응답 크기: {}", jsonData.length());
                    AggregatedData aggregatedData = AggregatedData.fromJson(jsonData);
                    return aggregatedData.getStreamingLogs();
                }))
                .collect(Collectors.toList());

        // 모든 CompletableFuture가 완료될 때까지 대기하고, 결과를 평탄화
        List<StreamingLog> allStreamingLogs = futureStreamingLogs.stream()
                .map(CompletableFuture::join)
                .flatMap(List::stream)
                .peek(log -> logger.debug("streamingLog 확인: {}", log))
                // 타임스탬프 기준 정렬
                .sorted(Comparator.comparing(StreamingLog::getTimestamp))
                .collect(Collectors.toList());

        logger.info("총 {}개의 스트리밍 로그가 정렬 및 필터링되었습니다.", allStreamingLogs.size());
        logger.info("findStreamingLogByArtistId 처리 완료 - artistId: {}", artistId);

        return allStreamingLogs;
    }


    /**
     * 특정 사용자의 특정 기간에 해당하는 스트리밍 로그를 조회합니다.
     *
     * @param listenerId 사용자 ID
     * @param startTime 검색 시작 시간
     * @param endTime 검색 종료 시간
     * @return 특정 사용자의 주어진 기간 내에 해당하는 스트리밍 로그 목록
     */
    public List<StreamingLog> findStreamingLogByUserIdAndPeriod(Integer listenerId,
                                                                LocalDateTime startTime, LocalDateTime endTime) {
        logger.info("findStreamingLogByUserIdAndPeriod 메서드 호출 - listenerId: {}, startTime: {}, endTime: {}",
                listenerId, startTime, endTime);

        List<StreamingAggregationContract.RawListenerTracksUpdatedEventResponse> events =
                streamingAggregationContractEventListener.getAllRawListenerTracksUpdatedEvents(startTime, endTime);
        logger.info("블록체인으로부터 {}개의 이벤트가 조회되었습니다.", events.size());
        logger.info("IPFS에서 데이터를 조회하고 처리 중입니다.");

        // 각 이벤트별로 비동기적으로 IPFS 데이터를 조회
        List<CompletableFuture<List<StreamingLog>>> futureStreamingLogs = events.stream()
                .map(event -> CompletableFuture.supplyAsync(() -> {
                    logger.info("IPFS 데이터 조회 시작. CID: {}", event.cid);
                    String jsonData = ipfsClient.get(event.cid);
                    logger.info("IPFS 데이터 조회 성공. 응답 크기: {}", jsonData.length());
                    AggregatedData aggregatedData = AggregatedData.fromJson(jsonData);
                    return aggregatedData.getStreamingLogs();
                }))
                .collect(Collectors.toList());

        // 모든 CompletableFuture가 완료될 때까지 대기하고, 결과를 평탄화
        List<StreamingLog> allStreamingLogs = futureStreamingLogs.stream()
                .map(CompletableFuture::join)
                .flatMap(List::stream)
                .peek(log -> logger.debug("streamingLog 확인: {}", log))
                // listenerId 기준으로만 필터링
                .filter(log -> log.getMemberId().equals(listenerId))
                // 타임스탬프 기준 정렬
                .sorted(Comparator.comparing(StreamingLog::getTimestamp))
                .collect(Collectors.toList());

        logger.info("총 {}개의 스트리밍 로그가 정렬 및 필터링되었습니다.", allStreamingLogs.size());
        logger.info("findStreamingLogByUserIdAndPeriod 처리 완료 - listenerId: {}", listenerId);

        return allStreamingLogs;
    }
}