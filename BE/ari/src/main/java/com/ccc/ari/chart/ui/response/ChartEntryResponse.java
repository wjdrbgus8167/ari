package com.ccc.ari.chart.ui.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ChartEntryResponse {
    private final Integer trackId;
    private final String trackTitle;
    private final String artist;
    private final String coverImageUrl;
    private final int rank;
}
