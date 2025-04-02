package com.ccc.ari.chart.application.service;

import com.ccc.ari.chart.application.repository.ChartCacheRepository;
import com.ccc.ari.chart.application.repository.ChartRepository;
import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.domain.entity.StreamingWindow;
import com.ccc.ari.chart.domain.service.ChartCreationService;
import com.ccc.ari.chart.domain.service.StreamingWindowService;
import com.ccc.ari.chart.infrastructure.repository.RedisWindowRepository;
import com.ccc.ari.global.event.AllAggregationCalculatedEvent;
import com.ccc.ari.global.event.GenreAggregationCalculatedEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ChartUpdateService {

    private static final Logger logger = LoggerFactory.getLogger(ChartUpdateService.class);
    private final StreamingWindowService streamingWindowService;
    private final ChartCreationService chartCreationService;
    private final ChartRepository chartRepository;
    private final ChartCacheRepository chartCacheRepository;
    private final RedisWindowRepository redisWindowRepository;

    @EventListener
    public void requestAllChartData(AllAggregationCalculatedEvent event) {
        logger.info("전체 차트 갱신을 위한 이벤트를 수신했습니다.");
        Map<Integer, Long> allTrackCounts = event.getTrackCounts();

        // Redis에서 기존 윈도우 조회
        Map<Integer, StreamingWindow> allTracksWindows = redisWindowRepository.getAllTracksWindows();

        // 현재 시간 기준으로 슬라이딩 윈도우 업데이트
        allTracksWindows = streamingWindowService.updateStreamingWindows(allTracksWindows, allTrackCounts, Instant.now());

        // 업데이트된 윈도우 Redis에 저장
        redisWindowRepository.saveAllTracksWindows(allTracksWindows);

        // 차트 생성
        Chart chart = chartCreationService.createChart(null, allTracksWindows);

        // 차트 저장 및 캐싱
        chartRepository.save(chart);
        chartCacheRepository.cacheAllChart(chart);

        logger.info("전체 차트가 성공적으로 갱신되었습니다. 트랙 수: {}", chart.getEntries().size());
    }

    @EventListener
    public void requestGenreChartData(GenreAggregationCalculatedEvent event) {
        logger.info("장르 차트 갱신을 위한 이벤트를 수신했습니다.");

        Map<Integer, Map<Integer, Long>> genreTrackCounts = event.getGenreTrackCounts();

        // 각 장르별로 윈도우 업데이트 및 차트 생성
        for (Map.Entry<Integer, Map<Integer, Long>> entry : genreTrackCounts.entrySet()) {
            Integer genreId = entry.getKey();
            Map<Integer, Long> trackCounts = entry.getValue();

            // Redis에서 기존 윈도우 조회
            Map<Integer, StreamingWindow> genreWindows = redisWindowRepository.getGenreTracksWindows(genreId);

            // 슬라이딩 윈도우 업데이트
            genreWindows = streamingWindowService.updateStreamingWindows(genreWindows, trackCounts, Instant.now());

            // 업데이트된 윈도우 Redis에 저장
            redisWindowRepository.saveGenreTracksWindows(genreId, genreWindows);

            // 차트 생성
            Chart genreChart = chartCreationService.createChart(genreId, genreWindows);

            // 차트 저장 및 캐싱
            chartRepository.save(genreChart);
            chartCacheRepository.cacheGenreChart(genreId, genreChart);

            logger.info("장르 ID {}의 차트가 성공적으로 갱신되었습니다. 트랙 수: {}", genreId, genreChart.getEntries().size());
        }
    }
}
