package com.ccc.ari.global.composition.response.chart;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class ChartResponse {

    private List<ChartItemDto> charts;

    @Getter
    @Builder
    public static class ChartItemDto {
        private Integer trackId;
        private Integer albumId;
        private String trackTitle;
        private String trackFileUrl;
        private String artist;
        private String coverImageUrl;
        private int rank;
    }
}
