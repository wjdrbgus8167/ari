package com.ccc.ari.chart.domain.vo;

import lombok.Getter;

import java.time.Instant;
import java.util.Objects;

@Getter
public class ChartPeriod {

    private final Instant start;
    private final Instant end;

    public ChartPeriod(Instant start, Instant end) {
        if (end.isBefore(start)) {
            throw new IllegalArgumentException("끝 시간은 반드시 시작 시간보다 이후이어야 합니다.");
        }

        if (end.toEpochMilli() - start.toEpochMilli() > 30L * 24 * 60 * 60 * 1000) {
            throw new IllegalArgumentException("차트 기간은 최대 30일입니다");
        }

        this.start = start;
        this.end = end;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof ChartPeriod period) {
            return period.getStart().equals(start) && period.getEnd().equals(end);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(start, end);
    }

    @Override
    public String toString() {
        return "차트 기간: " + start + " ~ " + end;
    }
}
