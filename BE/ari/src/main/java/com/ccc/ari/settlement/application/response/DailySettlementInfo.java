package com.ccc.ari.settlement.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class DailySettlementInfo {
    private final String date;
    private final Double settlement;
}