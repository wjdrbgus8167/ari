package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.application.repository.StreamingLogRepository;
import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.vo.AggregationPeriod;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AggregationBatchService {

    private final StreamingLogRepository streamingLogRepository;

    /**
     * 매 정각마다 Redis에 저장된 StreamingLog VO들을 가져와
     * 집계 기준(전체, 장르별, 아티스트별, 리스너별)에 따라 집계해
     * AggregatedData 객체를 생성합니다.
     * AggregationPeriod는 최근 1시간(UTC 기준)을 기준으로 설정합니다.
     *
     * 스케줄링 cron: "0 0 * * * *" (매 정각 0분 0초)
     */
    @Scheduled(cron = "0 0 * * * *")
    public void performAggregation() {
        // 1. Redis에 저장된 StreamingLog VO들을 원자적으로 가져오고 삭제
        List<StreamingLog> rawLogs = streamingLogRepository.getAllAndDelete("currentBatch");
        if (rawLogs == null || rawLogs.isEmpty()) {
            // 로그가 없으면 추가 작업 없이 종료
            return;
        }

        // 2. 집계 기간을 UTC 기준으로 최근 1시간으로 설정합니다.
        Instant now = Instant.now();
        AggregationPeriod period = new AggregationPeriod(now.minusSeconds(3600), now);

        // 3. 집계 기준 별 AggregatedData 생성
        // TODO: 도메인 서비스를 활용하여 집계 기준 별 AggregatedData 생성 메소드 호출
        AggregatedData aggregatedData = AggregatedData.builder()
                .period(period)
                .streamingLogs(rawLogs)
                .build();
    }
}
