package com.ccc.ari.settlement.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@Builder
public class GetMyArtistSettlementResponse {

    private final Double totalSettlement;
    private final List<CycleSettlementInfo> cycleSettlements;
}
