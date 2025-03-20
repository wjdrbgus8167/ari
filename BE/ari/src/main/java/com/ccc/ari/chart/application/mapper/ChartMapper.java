package com.ccc.ari.chart.application.mapper;

import com.ccc.ari.chart.application.dto.ChartResponseDto;
import com.ccc.ari.chart.domain.Chart;
import com.ccc.ari.chart.domain.vo.ChartEntry;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 차트 도메인 모델과 DTO 간 변환을 담당하는 매퍼
 */
@Component
public class ChartMapper {

    /**
     * 도메인 모델을 응답 DTO로 변환합니다.
     *
     * @param chart 차트 도메인 모델
     * @return 차트 응답 DTO
     */
    public ChartResponseDto toDto(Chart chart) {
        List<ChartResponseDto.ChartEntryDto> entryDtos = chart.getEntries().stream()
                .map(this::toEntryDto)
                .toList();

        return ChartResponseDto.builder()
                .startDate(chart.getPeriod().getStart())
                .endDate(chart.getPeriod().getEnd())
                .entries(entryDtos)
                .build();
    }

    /**
     * 차트 항목 도메인 객체를 DTO로 변환합니다.
     *
     * @param entry 차트 항목 도메인 객체
     * @return 차트 항목 DTO
     */
    private ChartResponseDto.ChartEntryDto toEntryDto(ChartEntry entry) {
        return ChartResponseDto.ChartEntryDto.builder()
                .trackId(entry.getTrackId())
                .trackTitle(entry.getTrackTitle())
                .rank(entry.getRank())
                .streamCount(entry.getStreamCount())
                .build();
    }
}
