package com.ccc.ari.aggregation.domain;

import com.ccc.ari.aggregation.domain.vo.AggregationPeriod;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import lombok.Builder;

import java.util.List;

@Builder
public class AggregatedData {

    // 집계 기간 VO
    private final AggregationPeriod period;
    // 스트리밍 로그 VO List
    private final List<StreamingLog> streamingLogs;

    public AggregatedData(AggregationPeriod period,
                          List<StreamingLog> streamingLogs) {
        this.period = period;
        this.streamingLogs = streamingLogs;
    }
}