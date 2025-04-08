package com.ccc.ari.aggregation.application.service.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class AlbumStreamingInfo {

    private final Integer albumId;
    private final Integer totalStreaming;
}
