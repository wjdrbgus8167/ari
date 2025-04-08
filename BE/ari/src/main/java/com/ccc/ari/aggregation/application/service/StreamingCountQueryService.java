package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.application.service.response.AlbumStreamingInfo;
import com.ccc.ari.aggregation.application.service.response.GetArtistStreamingResponse;
import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.aggregation.infrastructure.adapter.StreamingAggregationContractEventListener;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StreamingCountQueryService {

    private final StreamingAggregationContractEventListener streamingAggregationContractEventListener;
    private final TrackClient trackClient;
    private final IpfsClient ipfsClient;
    
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    public GetArtistStreamingResponse getArtistAlbumStreamings(Integer artistId) {

        logger.info("아티스트 ID {}의 스트리밍 데이터를 수집 시작", artistId);

        // 1. 해당 아티스트의 모든 스트리밍 집계 이벤트 수집
        List<StreamingAggregationContract.RawArtistTracksUpdatedEventResponse> events =
                streamingAggregationContractEventListener.getRawArtistTracksUpdatedEventsByArtistId(artistId);
        logger.info("아티스트 ID {}의 스트리밍 집계 이벤트 {}건 수집 완료", artistId, events.size());

        // 2. IPFS에서 비동기적으로 데이터 수집
        List<CompletableFuture<List<StreamingLog>>> futureStreamingLogs = events.stream()
                .map(event -> CompletableFuture.supplyAsync(() -> {
                    logger.info("CID {}의 데이터를 IPFS에서 조회 중...", event.cid);
                    String jsonData = ipfsClient.get(event.cid);
                    AggregatedData aggregatedData = AggregatedData.fromJson(jsonData);
                    logger.info("CID {}의 스트리밍 데이터를 성공적으로 조회", event.cid);
                    return aggregatedData.getStreamingLogs();
                }))
                .collect(Collectors.toList());

        // 3. 모든 스트리밍 로그 수집 및 처리
        List<StreamingLog> allStreamingLogs = futureStreamingLogs.stream()
                .map(CompletableFuture::join)
                .flatMap(List::stream)
                .collect(Collectors.toList());
        logger.info("아티스트 ID {}의 총 스트리밍 로그 {}건 수집 완료", artistId, allStreamingLogs.size());

        // 4. 앨범별 스트리밍 수 집계
        Map<Integer, Integer> albumStreamingCounts = allStreamingLogs.stream()
                .map(log -> {
                    TrackDto trackDto = trackClient.getTrackById(log.getTrackId());
                    logger.debug("트랙 ID {} -> 앨범 ID {} 매핑 완료", log.getTrackId(), trackDto.getAlbumId());
                    return trackDto.getAlbumId();
                })
                .collect(Collectors.groupingBy(
                        albumId -> albumId,
                        Collectors.collectingAndThen(Collectors.counting(), Long::intValue)
                ));
        logger.info("앨범별 스트리밍 집계 완료: {}개 앨범 처리 완료", albumStreamingCounts.size());

        // 5. AlbumStreamingInfo 리스트 생성
        List<AlbumStreamingInfo> albumStreamings = albumStreamingCounts.entrySet().stream()
                .map(entry -> AlbumStreamingInfo.builder()
                        .albumId(entry.getKey())
                        .totalStreaming(entry.getValue())
                        .build())
                .collect(Collectors.toList());
        logger.info("앨범 스트리밍 정보 객체 {}건 생성 완료", albumStreamings.size());

        // 6. 시간대별 스트리밍 카운트 계산
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        LocalDateTime todayStart = now.toLocalDate().atStartOfDay();
        LocalDateTime yesterdayStart = todayStart.minusDays(1);

        ZoneId kstZone = ZoneId.of("Asia/Seoul");

        int todayStreamingCount = (int) allStreamingLogs.stream()
                .filter(log -> LocalDateTime.ofInstant(log.getTimestamp(), kstZone)
                        .isAfter(todayStart))
                .count();
        logger.info("오늘({}) 스트리밍 수: {}건", todayStart, todayStreamingCount);

        int yesterdayStreamingCount = (int) allStreamingLogs.stream()
                .filter(log -> {
                    LocalDateTime logDateTime = LocalDateTime.ofInstant(log.getTimestamp(), kstZone);
                    return logDateTime.isAfter(yesterdayStart) &&
                            logDateTime.isBefore(todayStart);
                })
                .count();
        logger.info("어제({}) 스트리밍 수: {}건", yesterdayStart, yesterdayStreamingCount);

        int streamingDiff = todayStreamingCount - yesterdayStreamingCount;
        int totalStreamingCount = allStreamingLogs.size();
        logger.info("총 스트리밍 수: {}건, 오늘과 어제의 스트리밍 차이: {}건", totalStreamingCount, streamingDiff);

        // 7. 응답 객체 생성 및 반환
        GetArtistStreamingResponse response = GetArtistStreamingResponse.builder()
                .totalStreamingCount(totalStreamingCount)
                .todayStreamingCount(todayStreamingCount)
                .streamingDiff(streamingDiff)
                .albumStreamings(albumStreamings)
                .build();
        logger.info("아티스트 ID {}에 대한 스트리밍 응답 객체 생성 완료", artistId);

        return response;
    }
}
