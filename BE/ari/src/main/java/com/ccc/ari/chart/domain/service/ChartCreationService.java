package com.ccc.ari.chart.domain.service;

import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.domain.entity.StreamingWindow;
import com.ccc.ari.chart.domain.vo.ChartEntry;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 차트 생성 관련 도메인 로직을 처리하는 서비스
 */
@Service
@RequiredArgsConstructor
public class ChartCreationService {

    private static final Logger logger = LoggerFactory.getLogger(ChartCreationService.class);
    private final StreamingWindowService streamingWindowService;
    private final ChartRankingService chartRankingService;

    public Chart createChart(Integer genreId, Map<Integer, StreamingWindow> streamingWindows) {
        // 각 트랙의 총 스트리밍 횟수 계산
        Map<Integer, Long> totalStreamCounts = streamingWindowService.calculateAllStreamCounts(streamingWindows);

        // 차트 순위 계산
        List<ChartEntry> entries = chartRankingService.calculateRankings(totalStreamCounts);

        // 차트 객체 생성
        Chart chart = Chart.builder()
                .genreId(genreId)
                .entries(entries)
                .createdAt(LocalDateTime.now())
                .build();

        logger.info("차트 생성 완료: genreId={}, 항목 수={}", genreId, entries.size());
        return chart;
    }
}
