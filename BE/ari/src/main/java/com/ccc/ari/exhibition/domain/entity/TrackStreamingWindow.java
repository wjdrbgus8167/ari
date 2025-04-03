package com.ccc.ari.exhibition.domain.entity;

import com.ccc.ari.exhibition.domain.vo.DailyStreamCount;
import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * 트랙별 슬라이딩 윈도우 도메인 엔티티
 */
@Getter
public class TrackStreamingWindow {

    private final Integer trackId;
    private final List<DailyStreamCount> dailyCounts;

    @Builder
    public TrackStreamingWindow(Integer trackId, List<DailyStreamCount> dailyCounts) {
        this.trackId = trackId;
        this.dailyCounts = dailyCounts;
    }

    @JsonCreator
    protected TrackStreamingWindow() {
        this.trackId = null;
        this.dailyCounts = new ArrayList<>();
    }

    // 새 일간 스트리밍 카운트 추가
    public TrackStreamingWindow addDailyCount(DailyStreamCount newCount) {
        List<DailyStreamCount> updatedCounts = new ArrayList<>(dailyCounts);
        updatedCounts.add(newCount);

        return TrackStreamingWindow.builder()
                .trackId(this.trackId)
                .dailyCounts(updatedCounts)
                .build();
    }

    // 지정 날짜보다 오래된 데이터 제거
    public TrackStreamingWindow removeOldCounts(Instant cutoffTime) {
        List<DailyStreamCount> filteredCounts = dailyCounts.stream()
                .filter(count -> !count.getTimestamp().isBefore(cutoffTime))
                .toList();

        return TrackStreamingWindow.builder()
                .trackId(this.trackId)
                .dailyCounts(filteredCounts)
                .build();
    }
}
