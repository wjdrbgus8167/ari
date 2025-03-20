package com.ccc.ari.chart.infrastructure;

import com.ccc.ari.chart.domain.Chart;
import com.ccc.ari.chart.domain.vo.ChartEntry;
import com.ccc.ari.chart.domain.vo.ChartPeriod;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

@Component
public class ChartDocumentMapper {

    /**
     * 도메인 모델을 MongoDB 데이터로 변환
     */
    public ChartDocument toDocument(Chart chart) {
        // 차트 항목 변환
        List<ChartDocument.ChartEntryDocument> entryDocuments = chart.getEntries().stream()
                .map(entry -> ChartDocument.ChartEntryDocument.builder()
                        .trackId(entry.getTrackId())
                        .trackTitle(entry.getTrackTitle())
                        .rank(entry.getRank())
                        .streamCount(entry.getStreamCount())
                        .build())
                .toList();

        // 차트 문서 생성
        return ChartDocument.builder()
                .startDate(chart.getPeriod().getStart())
                .endDate(chart.getPeriod().getEnd())
                .createdAt(chart.getCreatedAt())
                .entries(entryDocuments)
                .build();
    }

    /**
     * MongoDB 데이터를 도메인 모델로 변환
     */
    public Chart toDomain(ChartDocument document) {
        // 차트 기간 생성
        ChartPeriod period = new ChartPeriod(document.getStartDate(), document.getEndDate());

        // 차트 항목 변환
        List<ChartEntry> entries = document.getEntries().stream()
                .map(entry -> new ChartEntry(
                        entry.getTrackId(),
                        entry.getTrackTitle(),
                        entry.getRank(),
                        entry.getStreamCount(),
                        entry.getArtist(),
                        entry.getCoverImageUrl()))
                .toList();

        // 차트 객체 생성
        return new Chart(period, entries, Instant.now());
    }
}
