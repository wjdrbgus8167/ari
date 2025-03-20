package com.ccc.ari.chart.application.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

/**
 * 차트 조회 응답 DTO
 * 클라이언트에 반환할 차트 데이터 형식을 정의합니다.
 */
@Getter
@Builder
public class ChartResponseDto {

    private final Instant startDate;
    private final Instant endDate;
    private final List<ChartEntryDto> entries;

    /**
     * 차트 항목 응답 DTO
     * 각 트랙의 차트 정보를 포함합니다.
     */
    @Getter
    @Builder
    public static class ChartEntryDto {
        private final Integer trackId;
        private final String trackTitle;
        private final int rank;
        private final long streamCount;
    }
}
