package com.ccc.ari.chart.domain.vo;

import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.util.Objects;

@Getter
public class ChartEntry {

    private final Integer trackId;
    private final long streamCount;
    private final int rank;

    @Builder
    public ChartEntry(Integer trackId, long streamCount, int rank) {
        this.trackId = trackId;
        this.streamCount = streamCount;
        this.rank = rank;
    }

    @JsonCreator
    protected ChartEntry() {
        this.trackId = null;
        this.streamCount = 0;
        this.rank = 0;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof ChartEntry entry) {
            return entry.getTrackId().equals(trackId) && entry.getRank() == rank;
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(trackId, rank);
    }

    @Override
    public String toString() {
        return rank + "위: 트랙 ID (" + trackId + "), 스트리밍 횟수: " + streamCount;
    }
}
