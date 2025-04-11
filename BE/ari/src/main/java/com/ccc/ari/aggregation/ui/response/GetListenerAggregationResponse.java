package com.ccc.ari.aggregation.ui.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@Builder
public class GetListenerAggregationResponse {

    private final List<ArtistCountResult> artistCountList;
}
