package com.ccc.ari.chart.domain.service;

import com.ccc.ari.chart.domain.entity.StreamingWindow;
import com.ccc.ari.chart.domain.vo.HourlyStreamCount;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * 슬라이딩 윈도우 관련 도메인 로직을 처리하는 서비스
 */
@Service
@RequiredArgsConstructor
public class StreamingWindowService {

    private static final Logger logger = LoggerFactory.getLogger(StreamingWindowService.class);
    private static final int WINDOW_SIZE_DAYS = 30;

    public Map<Integer, StreamingWindow> updateStreamingWindows(Map<Integer, StreamingWindow> currentWindows, Map<Integer, Long> newStreamCounts, Instant timestamp) {

        Map<Integer, StreamingWindow> updatedWindows = new HashMap<>(currentWindows);
        Instant cutoffTime = timestamp.minus(WINDOW_SIZE_DAYS, ChronoUnit.DAYS);

        // 각 트랙별로 윈도우 업데이트
        for (Map.Entry<Integer, Long> entry : newStreamCounts.entrySet()) {
            Integer trackId = entry.getKey();
            Long count = entry.getValue();

            // 트랙의 현재 윈도우 가져오기 또는 새로 생성
            StreamingWindow window = updatedWindows.getOrDefault(trackId, createEmptyWindow(trackId));

            // 오래된 데이터 제거 후 새 데이터 추가
            StreamingWindow updatedWindow = window.removeOldCounts(cutoffTime)
                    .addHourlyCount(new HourlyStreamCount(timestamp, count));

            updatedWindows.put(trackId, updatedWindow);
        }

        logger.info("{}개 트랙의 스트리밍 윈도우가 업데이트되었습니다.", updatedWindows.size());
        return updatedWindows;
    }

    // 빈 스트리밍 윈도우 생성
    private StreamingWindow createEmptyWindow(Integer trackId) {
        return StreamingWindow.builder()
                .trackId(trackId)
                .hourlyCounts(new ArrayList<>())
                .build();
    }

    /**
     * 윈도우 내의 총 스트리밍 횟수 계산
     *
     * @param window 스트리밍 윈도우
     * @return 총 스트리밍 횟수
     */
    public long calculateTotalStreamCount(StreamingWindow window) {
        if (window == null || window.getHourlyCounts() == null || window.getHourlyCounts().isEmpty()) {
            return 0;
        }

        return window.getHourlyCounts().stream()
                .mapToLong(HourlyStreamCount::getCount)
                .sum();
    }

    /**
     * 여러 윈도우의 총 스트리밍 횟수를 한 번에 계산
     *
     * @param windows 스트리밍 윈도우 맵 (trackId -> StreamingWindow)
     * @return 각 트랙별 총 스트리밍 횟수 맵 (trackId -> totalCount)
     */
    public Map<Integer, Long> calculateAllStreamCounts(Map<Integer, StreamingWindow> windows) {
        if (windows == null || windows.isEmpty()) {
            return new HashMap<>();
        }

        Map<Integer, Long> totalCounts = new HashMap<>();

        for (Map.Entry<Integer, StreamingWindow> entry : windows.entrySet()) {
            Integer trackId = entry.getKey();
            StreamingWindow window = entry.getValue();

            long totalCount = calculateTotalStreamCount(window);
            totalCounts.put(trackId, totalCount);
        }

        return totalCounts;
    }
}
