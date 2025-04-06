package com.ccc.ari.aggregation.ui.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class ArtistCountResult {

    private final Integer artistId;
    private final Integer count;
}
