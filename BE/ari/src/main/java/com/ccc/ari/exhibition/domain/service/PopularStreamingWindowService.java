package com.ccc.ari.exhibition.domain.service;

import com.ccc.ari.exhibition.domain.entity.TrackStreamingWindow;
import com.ccc.ari.exhibition.domain.vo.DailyStreamCount;
import lombok.RequiredArgsConstructor;
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
public class PopularStreamingWindowService {

    private static final int WINDOW_SIZE_DAYS = 7;

    // 윈도우 업데이트 (새 데이터 추가, 오래된 데이터 제거)
    public Map<Integer, TrackStreamingWindow> updateStreamingWindows(Map<Integer, TrackStreamingWindow> currentWindows, Map<Integer, Long> newStreamCounts, Instant timestamp) {
        Map<Integer, TrackStreamingWindow> updatedWindows = new HashMap<>(currentWindows);
        Instant cutoffTime = timestamp.minus(WINDOW_SIZE_DAYS, ChronoUnit.DAYS);

        // 각 트랙별로 윈도우 업데이트
        for (Map.Entry<Integer, Long> entry : newStreamCounts.entrySet()) {
            Integer trackId = entry.getKey();
            Long count = entry.getValue();

            // 트랙의 현재 윈도우 가져오기 또는 새로 생성
            TrackStreamingWindow window = updatedWindows.getOrDefault(trackId, createEmptyWindow(trackId));

            // 오래된 데이터 제거 후 새 데이터 추가
            TrackStreamingWindow updatedWindow = window.removeOldCounts(cutoffTime)
                    .addDailyCount(new DailyStreamCount(timestamp, count));

            updatedWindows.put(trackId, updatedWindow);
        }

        return updatedWindows;
    }

    // 빈 스트리밍 윈도우 생성
    private TrackStreamingWindow createEmptyWindow(Integer trackId) {
        return TrackStreamingWindow.builder()
                .trackId(trackId)
                .dailyCounts(new ArrayList<>())
                .build();
    }

    // 윈도우 내의 총 스트리밍 횟수 계산
    public long calculateTotalStreamCount(TrackStreamingWindow window) {
        if (window == null || window.getDailyCounts() == null || window.getDailyCounts().isEmpty()) {
            return 0;
        }

        return window.getDailyCounts().stream()
                .mapToLong(DailyStreamCount::getCount)
                .sum();
    }

    // 여러 윈도우의 총 스트리밍 횟수를 한 번에 계산
    public Map<Integer, Long> calculateAllStreamCounts(Map<Integer, TrackStreamingWindow> windows) {
        if (windows == null || windows.isEmpty()) {
            return new HashMap<>();
        }

        Map<Integer, Long> totalCounts = new HashMap<>();

        for (Map.Entry<Integer, TrackStreamingWindow> entry : windows.entrySet()) {
            Integer trackId = entry.getKey();
            TrackStreamingWindow window = entry.getValue();

            long totalCount = calculateTotalStreamCount(window);
            totalCounts.put(trackId, totalCount);
        }

        return totalCounts;
    }
}
