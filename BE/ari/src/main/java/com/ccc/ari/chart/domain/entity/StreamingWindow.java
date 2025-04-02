package com.ccc.ari.chart.domain.entity;

import com.ccc.ari.chart.domain.vo.HourlyStreamCount;
import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * 슬라이딩 윈도우를 관리하기 위한 엔티티
 */
@Getter
public class StreamingWindow {

    private final Integer trackId;
    private final List<HourlyStreamCount> hourlyCounts;

    @Builder
    public StreamingWindow(Integer trackId, List<HourlyStreamCount> hourlyCounts) {
        this.trackId = trackId;
        this.hourlyCounts = hourlyCounts;
    }

    @JsonCreator
    protected StreamingWindow() {
        this.trackId = null;
        this.hourlyCounts = new ArrayList<>();
    }

    // 새로운 시간별 스트리밍 카운트를 추가한 새 객체 생성
    public StreamingWindow addHourlyCount(HourlyStreamCount newCount) {
        List<HourlyStreamCount> updatedCounts = new ArrayList<>(hourlyCounts);
        updatedCounts.add(newCount);

        return StreamingWindow.builder()
                .trackId(this.trackId)
                .hourlyCounts(updatedCounts)
                .build();
    }

    // 지정된 시간 이전의 오래된 카운트를 제거한 새 객체를 생성
    public StreamingWindow removeOldCounts(Instant cutoffTime) {
        List<HourlyStreamCount> filteredCounts = hourlyCounts.stream()
                .filter(count -> !count.getTimestamp().isBefore(cutoffTime))
                .toList();

        return StreamingWindow.builder()
                .trackId(this.trackId)
                .hourlyCounts(filteredCounts)
                .build();
    }
}
