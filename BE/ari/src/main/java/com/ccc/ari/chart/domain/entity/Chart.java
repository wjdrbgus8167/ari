package com.ccc.ari.chart.domain.entity;

import com.ccc.ari.chart.domain.vo.ChartEntry;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Getter
public class Chart {

    private final Integer genreId;
    private final List<ChartEntry> entries;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private final LocalDateTime createdAt;

    @Builder
    public Chart(Integer genreId, List<ChartEntry> entries, LocalDateTime createdAt) {
        if (entries.size() > 50) {
            throw new IllegalArgumentException("차트에는 최대 50개의 트랙만 포함될 수 있습니다.");
        }

        this.genreId = genreId;
        this.entries = List.copyOf(entries); // 불변 리스트로 저장
        this.createdAt = createdAt;
    }

    @JsonCreator
    protected Chart() {
        this.genreId = null;
        this.entries = new ArrayList<>();
        this.createdAt = null;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Chart chart) {
            return chart.getGenreId().equals(genreId) && chart.getCreatedAt().equals(createdAt);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(genreId, createdAt);
    }
}
