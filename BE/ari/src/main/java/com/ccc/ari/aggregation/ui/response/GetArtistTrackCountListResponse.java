package com.ccc.ari.aggregation.ui.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class GetArtistTrackCountListResponse {

    private final List<TrackCountResult> trackCountList;
}
