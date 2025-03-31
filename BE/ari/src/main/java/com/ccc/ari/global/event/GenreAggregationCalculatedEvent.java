package com.ccc.ari.global.event;

import lombok.Builder;
import lombok.Getter;

import java.util.Map;

@Getter
@Builder
public class GenreAggregationCalculatedEvent {

    private final Map<Integer, Map<Integer, Long>> genreTrackCounts;

    public GenreAggregationCalculatedEvent(Map<Integer, Map<Integer, Long>> genreTrackCounts) {
        this.genreTrackCounts = genreTrackCounts;
    }
}
