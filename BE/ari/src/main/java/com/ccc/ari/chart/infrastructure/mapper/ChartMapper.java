package com.ccc.ari.chart.infrastructure.mapper;

import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.domain.vo.ChartEntry;
import com.ccc.ari.chart.infrastructure.entity.MongoChart;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 도메인 엔티티와 MongoDB 엔티티 간의 변환을 담당하는 매퍼
 */
@Component
public class ChartMapper {

    /**
     * 도메인 엔티티를 MongoDB 엔티티로 변환합니다.
     */
    public MongoChart toMongoEntity(Chart chart) {
        List<MongoChart.MongoChartEntry> mongoEntries = chart.getEntries().stream()
                .map(this::toMongoEntry)
                .toList();

        return MongoChart.builder()
                .genreId(chart.getGenreId())
                .createdAt(chart.getCreatedAt())
                .entries(mongoEntries)
                .build();
    }

    /**
     * MongoDB 엔티티를 도메인 엔티티로 변환합니다.
     */
    public Chart toDomainEntity(MongoChart mongoChart) {
        List<ChartEntry> entries = mongoChart.getEntries().stream()
                .map(this::toDomainEntry)
                .toList();

        return Chart.builder()
                .genreId(mongoChart.getGenreId())
                .createdAt(mongoChart.getCreatedAt())
                .entries(entries)
                .build();
    }

    /**
     * 도메인 차트 엔트리를 MongoDB 차트 엔트리로 변환합니다.
     */
    private MongoChart.MongoChartEntry toMongoEntry(ChartEntry entry) {
        return MongoChart.MongoChartEntry.builder()
                .trackId(entry.getTrackId())
                .streamCount(entry.getStreamCount())
                .rank(entry.getRank())
                .build();
    }

    /**
     * MongoDB 차트 엔트리를 도메인 차트 엔트리로 변환합니다.
     */
    private ChartEntry toDomainEntry(MongoChart.MongoChartEntry mongoEntry) {
        return ChartEntry.builder()
                .trackId(mongoEntry.getTrackId())
                .streamCount(mongoEntry.getStreamCount())
                .rank(mongoEntry.getRank())
                .build();
    }
}
