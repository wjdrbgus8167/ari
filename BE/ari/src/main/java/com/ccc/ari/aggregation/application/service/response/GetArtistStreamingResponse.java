package com.ccc.ari.aggregation.application.service.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@Builder
public class GetArtistStreamingResponse {

    private final Integer totalStreamingCount;
    private final Integer todayStreamingCount;
    private final Integer streamingDiff;
    private final List<AlbumStreamingInfo> albumStreamings;
}
