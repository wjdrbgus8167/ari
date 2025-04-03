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
import java.util.ArrayList;
import java.util.HashMap;
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

        // 3. 전체 스트리밍 집계 처리
        try {
            AggregatedData aggregatedData = AggregatedData.builder()
                    .period(period)
                    .streamingLogs(rawLogs)
                    .build();
            logger.debug("생성된 AggregatedData 상세 정보: {}", aggregatedData);
            logger.info("AggregatedData 객체를 생성했습니다. JSON 출력: {}", aggregatedData.toJson());
            eventPublisher.publishEvent(new AggregationCompletedEvent(aggregatedData));
            logger.info("전체 집계 이벤트가 성공적으로 발행되었습니다.");
        } catch (Exception e) {
            logger.error("전체 집계 중 오류 발생: {}", e.getMessage(), e);
            throw e;
        }

        // 4. 그룹별 집계를 위한 로그 분류 (한 번의 순회로 세 그룹을 동시에 분류)
        Map<Integer, List<StreamingLog>> genreLogs = new HashMap<>();
        Map<Integer, List<StreamingLog>> artistLogs = new HashMap<>();
        Map<Integer, List<StreamingLog>> listenerLogs = new HashMap<>();

        for (StreamingLog log : rawLogs) {
            genreLogs.computeIfAbsent(log.getGenreId(), k -> new ArrayList<>()).add(log);
            artistLogs.computeIfAbsent(log.getArtistId(), k -> new ArrayList<>()).add(log);
            listenerLogs.computeIfAbsent(log.getMemberId(), k -> new ArrayList<>()).add(log);
        }

        // 5. 각 그룹별 집계 이벤트 발행 (공통 로직을 별도 메서드로 추출)
        processAggregationGroup(genreLogs, AggregationCompletedEvent.AggregationType.GENRE, period);
        processAggregationGroup(artistLogs, AggregationCompletedEvent.AggregationType.ARTIST, period);
        processAggregationGroup(listenerLogs, AggregationCompletedEvent.AggregationType.LISTENER, period);
    }

    private void processAggregationGroup(Map<Integer, List<StreamingLog>> groupMap,
                                             AggregationCompletedEvent.AggregationType aggregationType,
                                             AggregationPeriod period) {
        groupMap.forEach((id, logs) -> {
            try {
                AggregatedData aggregatedData = AggregatedData.builder()
                        .period(period)
                        .streamingLogs(logs)
                        .build();
                eventPublisher.publishEvent(new AggregationCompletedEvent(aggregationType, aggregatedData, id));
                logger.info("{} 집계 이벤트가 성공적으로 발행되었습니다. ID: {}", aggregationType, id);
            } catch (Exception e) {
                logger.error("{} 집계 중 오류 발생: {}. ID: {}", aggregationType, e.getMessage(), id, e);
            }
        });
    }
}