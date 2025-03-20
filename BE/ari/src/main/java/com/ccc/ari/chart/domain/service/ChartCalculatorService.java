package com.ccc.ari.chart.domain.service;

import com.ccc.ari.chart.domain.Chart;
import com.ccc.ari.chart.domain.client.StreamingLogRecord;
import com.ccc.ari.chart.domain.vo.ChartEntry;
import com.ccc.ari.chart.domain.vo.ChartPeriod;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 차트 계산 도메인 서비스
 * 스트리밍 로그를 분석하여,
 * 상위 50개 트랙으로 차트를 생성하는 비즈니스 로직을 담당합니다.
 */
public class ChartCalculatorService {

    private static final Logger logger = LoggerFactory.getLogger(ChartCalculatorService.class);
    private static final int CHART_SIZE = 50;

    public Chart createChart(List<StreamingLogRecord> streamingLogs, ChartPeriod period) {
        logger.info("차트 생성 시작: 기간 {} ~ {}", period.getStart(), period.getEnd());

        // 1. 기간에 해당하는 로그만 필터링합니다.
        List<StreamingLogRecord> filteredLogs = filterLogsByPeriod(streamingLogs, period);
        logger.info("필터링된 로그 수: {}", filteredLogs.size());

        // 2. 트랙별 재생 횟수를 집계합니다.
        Map<Integer, Long> trackPlayCounts = new HashMap<>();
        Map<Integer, String> trackTitles = new HashMap<>();

        calculateTrackData(filteredLogs, trackPlayCounts, trackTitles);
        logger.info("집계된 트랙 수: {}", trackPlayCounts.size());

        // 3. 상위 50개 트랙 선택 및 차트 리스트 생성
        List<ChartEntry> entries = createChartEntries(trackPlayCounts, trackTitles);
        logger.info("차트 항목 생성 완료: {} 트랙", entries.size());

        // 4. 차트 생성
        Chart chart = new Chart(period, entries);
        logger.info("차트 생성 완료!");

        return chart;
    }

    /**
     * 주어진 기간에 해당하는 로그만 필터링합니다.
     */
    private List<StreamingLogRecord> filterLogsByPeriod(List<StreamingLogRecord> logs, ChartPeriod period) {
        return logs.stream()
                .filter(log -> !log.getTimestamp().isBefore(period.getStart()) &&
                        !log.getTimestamp().isAfter(period.getEnd()))
                .toList();
    }

    /**
     * 필터링된 로그에서 트랙별 재생 횟수와 제목을 집계합니다.
     */
    private void calculateTrackData(List<StreamingLogRecord> logs, Map<Integer, Long> trackPlayCounts, Map<Integer, String> trackTitles) {

        for (StreamingLogRecord log : logs) {
            Integer trackId = log.getTrackId();

            trackPlayCounts.merge(trackId, 1L, Long::sum);

            if (!trackTitles.containsKey(trackId)) {
                trackTitles.put(trackId, log.getTrackTitle());
            }
        }
    }

    /**
     * 트랙별 재생 횟수를 기준으로 상위 50개 트랙의 차트 리스트를 생성합니다.
     */
    private List<ChartEntry> createChartEntries(Map<Integer, Long> trackPlayCounts, Map<Integer, String> trackTitles) {

        // 재생 횟수 기준 내림차순 정렬 후 상위 50개 선택
        List<Map.Entry<Integer, Long>> topTracks = trackPlayCounts.entrySet().stream()
                .sorted(Map.Entry.<Integer, Long>comparingByValue().reversed())
                .limit(CHART_SIZE)
                .toList();

        // 차트 리스트 생성
        List<ChartEntry> entries = new ArrayList<>();
        int rank = 1;

        for (Map.Entry<Integer, Long> entry : topTracks) {
            Integer trackId = entry.getKey();
            Long playCount = entry.getValue();

            // 미리 저장한 맵에서 제목 조회
            String trackTitle = trackTitles.getOrDefault(trackId, "Unknown Track");

            entries.add(new ChartEntry(trackId, trackTitle, rank++, playCount));
        }

        return entries;
    }
}
