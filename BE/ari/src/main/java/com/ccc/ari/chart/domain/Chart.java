package com.ccc.ari.chart.domain;

import com.ccc.ari.chart.domain.vo.ChartEntry;
import com.ccc.ari.chart.domain.vo.ChartPeriod;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.Objects;

@Builder
@Getter
public class Chart {

    private final ChartPeriod period;
    private final List<ChartEntry> entries;
    private final Instant createdAt;

    public Chart(ChartPeriod period, List<ChartEntry> entries) {
        if (entries.size() > 50) {
            throw new IllegalArgumentException("차트에는 최대 50개의 트랙만 포함될 수 있습니다.");
        }
        this.period = period;
        this.entries = List.copyOf(entries); // 불변 리스트로 저장
        this.createdAt = Instant.now();
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Chart chart) {
            return chart.getPeriod().equals(period) && chart.getEntries().equals(entries);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(period, entries);
    }

    @Override
    public String toString() {
        return "차트 기간: " + period + "\n" +
                "차트 목록:\n" + String.join("\n", entries.stream().map(ChartEntry::toString).toList());
    }
}
