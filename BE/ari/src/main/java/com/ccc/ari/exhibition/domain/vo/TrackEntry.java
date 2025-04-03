package com.ccc.ari.exhibition.domain.vo;

import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.util.Objects;

@Getter
public class TrackEntry {

    private final Integer trackId;
    private final long streamCount;

    @Builder
    public TrackEntry(Integer trackId, long streamCount) {
        this.trackId = trackId;
        this.streamCount = streamCount;
    }

    @JsonCreator
    protected TrackEntry() {
        this.trackId = null;
        this.streamCount = 0;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof TrackEntry entry) {
            return entry.getTrackId().equals(trackId);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(trackId);
    }
}
