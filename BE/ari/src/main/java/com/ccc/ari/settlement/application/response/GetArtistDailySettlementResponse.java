package com.ccc.ari.settlement.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@Builder
public class GetArtistDailySettlementResponse {
    private final Double todaySettlement;
    private final Double settlementDiff;
    private final List<HourlySettlementInfo> hourlySettlements;
}
