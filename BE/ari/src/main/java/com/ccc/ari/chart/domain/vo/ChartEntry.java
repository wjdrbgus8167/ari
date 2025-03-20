package com.ccc.ari.chart.domain.vo;

import lombok.Getter;

import java.util.Objects;

@Getter
public class ChartEntry {

    private final Integer trackId;
    private final String trackTitle;
    private final int rank;
    private final long streamCount;
    private final String artist;
    private final String coverImageUrl;

    public ChartEntry(Integer trackId, String trackTitle, int rank, long streamCount, String artist, String coverImageUrl) {
        this.trackId = trackId;
        this.trackTitle = trackTitle;
        this.rank = rank;
        this.streamCount = streamCount;
        this.artist = artist;
        this.coverImageUrl = coverImageUrl;
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
        return rank + "위: " + trackTitle + "(id:" + trackId + "), 스트리밍 횟수: " + streamCount;
    }
}
