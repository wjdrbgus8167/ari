package com.ccc.ari.chart.domain.vo;

import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.Objects;

@Getter
public class HourlyStreamCount {

    private final Instant timestamp;
    private final long count;

    @Builder
    public HourlyStreamCount(Instant timestamp, long count) {
        this.timestamp = timestamp;
        this.count = count;
    }

    @JsonCreator
    protected HourlyStreamCount() {
        this.timestamp = null;
        this.count = 0;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof HourlyStreamCount hourlyCount) {
            return hourlyCount.getTimestamp().equals(timestamp) && hourlyCount.getCount() == count;
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(timestamp, count);
    }
}
