package com.ccc.ari.global.event;

import lombok.Builder;
import lombok.Getter;

import java.util.Map;

@Getter
@Builder
public class AllAggregationCalculatedEvent {

    private final Map<Integer, Long> trackCounts;

    public AllAggregationCalculatedEvent(Map<Integer, Long> trackCounts) {
        this.trackCounts = trackCounts;
    }
}
