package com.ccc.ari.aggregation.ui.response;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class TrackCountResult {

    private final Integer trackId;
    private final Integer totalCount;
    private final Integer monthCount;
}
