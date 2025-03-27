package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.application.repository.StreamingLogRepository;
import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.vo.AggregationPeriod;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.aggregation.event.AggregationCompletedEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AggregationBatchService {

    private final StreamingLogRepository streamingLogRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final Logger logger = LoggerFactory.getLogger(AggregationBatchService.class);

    /**
     * 매 정각마다 Redis에 저장된 StreamingLog VO들을 가져와
     * 집계 기준(전체, 장르별, 아티스트별, 리스너별)에 따라 집계해
     * AggregatedData 객체를 생성합니다.
     * AggregationPeriod는 최근 1시간(UTC 기준)을 기준으로 설정합니다.
     * <p>
     * 스케줄링 cron: "0 0 * * * *" (매 정각 0분 0초)
     */
    @Scheduled(cron = "0 0 * * * *")
    public void performAggregation() {
        logger.info("집계 배치 작업을 시작합니다.");

        // 1. Redis에 저장된 StreamingLog VO들을 원자적으로 가져오고 삭제
        List<StreamingLog> rawLogs = streamingLogRepository.getAllAndDelete("currentBatch");
        if (rawLogs == null || rawLogs.isEmpty()) {
            logger.info("배치 작업 실행 시점에 처리할 스트리밍 로그가 없습니다.");
            return;
        }
        logger.info("총 {}개의 스트리밍 로그를 가져왔습니다.", rawLogs.size());

        // 2. 집계 기간을 UTC 기준으로 최근 1시간으로 설정합니다.
        Instant now = Instant.now();
        AggregationPeriod period = new AggregationPeriod(now.minusSeconds(3600), now);
        logger.info("집계 기간이 설정되었습니다: {}", period);

        // 3. 집계 기준 별 AggregatedData 생성 및 AggregationCompletedEvent 발행
        // 3.1 전체 스트리밍 집계
        try {
            AggregatedData aggregatedData = AggregatedData.builder()
                    .period(period)
                    .streamingLogs(rawLogs)
                    .build();
            logger.debug("생성된 AggregatedData 상세 정보: {}", aggregatedData);
            logger.info("AggregatedData 객체를 생성했습니다. JSON 출력: {}", aggregatedData.toJson());

            eventPublisher.publishEvent(new AggregationCompletedEvent(aggregatedData));
            logger.info("전체 집계 이벤트가 성공적으로 발행되었습니다.");

            Map<Integer, List<StreamingLog>> genreLogGroups = aggregatedData.getStreamingLogs().stream()
                    .collect(Collectors.groupingBy(StreamingLog::getGenreId));
            logger.info("스트리밍 그룹핑 완료");

        } catch (Exception e) {
            logger.error("전체 집계 중 오류 발생: {}", e.getMessage(), e);
            throw e;
        }
        // 3.2 장르별 스트리밍 집계
        Map<Integer, List<StreamingLog>> genreLogGroups = rawLogs.stream()
                .collect(Collectors.groupingBy(StreamingLog::getGenreId));

        genreLogGroups.forEach((genreId, genreLogs) -> {
            try {
                AggregatedData genreAggregatedData = AggregatedData.builder()
                        .period(period)
                        .streamingLogs(genreLogs)
                        .build();

                eventPublisher.publishEvent(new AggregationCompletedEvent(
                        AggregationCompletedEvent.AggregationType.GENRE,
                        genreAggregatedData,
                        genreId
                ));
                logger.info("장르(ID:{}) 집계 이벤트가 성공적으로 발행되었습니다.", genreId);
            } catch (Exception e) {
                logger.error("장르(ID:{}) 집계 중 오류 발생: {}", genreId, e.getMessage(), e);
            }
        });
        // 3.3 아티스트별 스트리밍 집계
        Map<Integer, List<StreamingLog>> artistLogGroups = rawLogs.stream()
                .collect(Collectors.groupingBy(StreamingLog::getArtistId));

        artistLogGroups.forEach((artistId, artistLogs) -> {
            try {
                AggregatedData artistAggregatedData = AggregatedData.builder()
                        .period(period)
                        .streamingLogs(artistLogs)
                        .build();

                eventPublisher.publishEvent(new AggregationCompletedEvent(
                        AggregationCompletedEvent.AggregationType.ARTIST,
                        artistAggregatedData,
                        artistId
                ));
                logger.info("아티스트(ID:{}) 집계 이벤트가 성공적으로 발행되었습니다.", artistId);
            } catch (Exception e) {
                logger.error("아티스트(ID:{}) 집계 중 오류 발생: {}", artistId, e.getMessage(), e);
            }
        });
        // 3.4 리스너별 스트리밍 집계
        Map<Integer, List<StreamingLog>> listenerLogGroups = rawLogs.stream()
                .collect(Collectors.groupingBy(StreamingLog::getMemberId));

        listenerLogGroups.forEach((listenerId, listenerLogs) -> {
            try {
                AggregatedData listenerAggregatedData = AggregatedData.builder()
                        .period(period)
                        .streamingLogs(listenerLogs)
                        .build();

                eventPublisher.publishEvent(new AggregationCompletedEvent(
                        AggregationCompletedEvent.AggregationType.LISTENER,
                        listenerAggregatedData,
                        listenerId
                ));
                logger.info("리스너(ID:{}) 집계 이벤트가 성공적으로 발행되었습니다.", listenerId);
            } catch (Exception e) {
                logger.error("리스너(ID:{}) 집계 중 오류 발생: {}", listenerId, e.getMessage(), e);
            }
        });
    }
}