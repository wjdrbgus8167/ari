package com.ccc.ari.settlement.application.command;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class GetMyRegularSettlementDetailCommand {

    private final Integer subscriberId;
    private final Integer cycleId;
}
