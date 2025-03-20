package com.ccc.ari.aggregation.event;

import com.ccc.ari.aggregation.domain.AggregatedData;
import lombok.Getter;

/**
 * AggregationBatchService가 AggregatedData를 생성한 이후,
 * AggregationOnChainApplicationService를 호출하기 위한 이벤트입니다.
 */
@Getter
public class AggregationCompletedEvent {

    private final AggregatedData aggregatedData;

    public AggregationCompletedEvent(AggregatedData aggregatedData) {
        this.aggregatedData = aggregatedData;
    }
}
