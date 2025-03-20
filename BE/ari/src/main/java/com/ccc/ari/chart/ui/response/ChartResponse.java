package com.ccc.ari.chart.ui.response;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

@Getter
@Builder
public class ChartResponse {
    private final Instant startDate;
    private final Instant endDate;
    private final List<ChartEntryResponse> charts;
}
