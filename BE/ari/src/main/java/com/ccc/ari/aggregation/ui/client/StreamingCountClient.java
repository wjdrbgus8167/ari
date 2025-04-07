package com.ccc.ari.aggregation.ui.client;

import com.ccc.ari.aggregation.application.service.StreamingLogQueryService;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.aggregation.ui.response.ArtistCountResult;
import com.ccc.ari.aggregation.ui.response.GetArtistTrackCountListResponse;
import com.ccc.ari.aggregation.ui.response.GetListenerAggregationResponse;
import com.ccc.ari.aggregation.ui.response.TrackCountResult;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class StreamingCountClient {

    private final StreamingLogQueryService streamingLogQueryService;

    
    /**
     * 주어진 아티스트 ID로 스트리밍 로그를 조회하여 누적 및 월별 트랙별 스트리밍 횟수를 계산합니다.
     *
     * @param artistId 조회할 아티스트 ID
     * @return 트랙별 스트리밍 횟수 결과 리스트를 포함하는 응답 객체
     */
    public GetArtistTrackCountListResponse getArtistTrackCounts(Integer artistId) {
        // 아티스트의 모든 스트리밍 로그 조회
        List<StreamingLog> streamingLogs = streamingLogQueryService.findStreamingLogByArtistId(artistId);

        // 현재 달의 시작일
        LocalDateTime monthStart = LocalDateTime.now().with(TemporalAdjusters.firstDayOfMonth());

        // 트랙별로 그룹화하여 전체 카운트와 월간 카운트 계산
        Map<Integer, TrackCountResult> trackCounts = streamingLogs.stream()
                .collect(Collectors.groupingBy(
                        StreamingLog::getTrackId,
                        Collectors.collectingAndThen(
                                Collectors.toList(),
                                logs -> {
                                    int totalCount = logs.size();
                                    int monthCount = (int) logs.stream()
                                            .filter(log -> {
                                                LocalDateTime timestamp = LocalDateTime.ofInstant(
                                                        log.getTimestamp(),
                                                        ZoneId.systemDefault()
                                                );
                                                return !timestamp.isBefore(monthStart);
                                            })
                                            .count();

                                    return TrackCountResult.builder()
                                            .trackId(logs.get(0).getTrackId())
                                            .totalCount(totalCount)
                                            .monthCount(monthCount)
                                            .build();
                                }
                        )
                ));

        // 결과를 리스트로 변환 후 반환
        return GetArtistTrackCountListResponse.builder()
                .trackCountList(new ArrayList<>(trackCounts.values()))
                .build();
    }

    public GetListenerAggregationResponse getListenerAggregation(Integer subscriptionId,
                                                                 LocalDateTime startTime, LocalDateTime endTime) {
        // 아티스트의 모든 스트리밍 로그 조회
        List<StreamingLog> streamingLogs =
                streamingLogQueryService.findStreamingLogByUserIdAndPeriod(subscriptionId, startTime, endTime);

        // 주어진 기간에 해당하는 로그만 필터링
        Map<Integer, Long> artistCounts = streamingLogs.stream()
                // 아티스트 ID로 그룹화하고 각 아티스트별 카운트 계산
                .collect(Collectors.groupingBy(
                        StreamingLog::getArtistId,
                        Collectors.counting()
                ));

        // ArtistCountResult 리스트 생성
        List<ArtistCountResult> artistCountResults = artistCounts.entrySet().stream()
                .map(entry -> ArtistCountResult.builder()
                        .artistId(entry.getKey())
                        .count(entry.getValue().intValue())
                        .build())
                .collect(Collectors.toList());

        // 최종 응답 객체 생성 및 반환
        return GetListenerAggregationResponse.builder()
                .artistCountList(artistCountResults)
                .build();
    }
}
