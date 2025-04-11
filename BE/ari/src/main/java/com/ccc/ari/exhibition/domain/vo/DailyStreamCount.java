package com.ccc.ari.exhibition.domain.vo;

import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.Objects;

@Getter
public class DailyStreamCount {

    private final Instant timestamp;
    private final long count;

    @Builder
    public DailyStreamCount(Instant timestamp, long count) {
        this.timestamp = timestamp;
        this.count = count;
    }

    @JsonCreator
    protected DailyStreamCount() {
        this.timestamp = null;
        this.count = 0;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof DailyStreamCount dailyCount) {
            return dailyCount.getTimestamp().equals(timestamp) && dailyCount.getCount() == count;
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(timestamp, count);
    }
}
