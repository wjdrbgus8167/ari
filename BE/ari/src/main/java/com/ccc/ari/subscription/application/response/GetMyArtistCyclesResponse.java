package com.ccc.ari.subscription.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@Builder
public class GetMyArtistCyclesResponse {

    private final List<CycleInfo> cycleInfos;
}
