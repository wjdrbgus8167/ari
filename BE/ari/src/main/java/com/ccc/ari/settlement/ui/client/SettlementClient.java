package com.ccc.ari.settlement.ui.client;

import com.ccc.ari.settlement.application.command.GetMyRegularSettlementDetailCommand;
import com.ccc.ari.settlement.application.response.RegularSettlementDetailResponse;
import com.ccc.ari.settlement.application.service.SettlementQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SettlementClient {

    private final SettlementQueryService settlementQueryService;

    public RegularSettlementDetailResponse getMyRegularSettlementDetail(Integer subscriberId,
                                                                        Integer cycleId) {
        return settlementQueryService.getMyRegularSettlementDetail(GetMyRegularSettlementDetailCommand.builder()
                                                                            .subscriberId(subscriberId)
                                                                            .cycleId(cycleId)
                                                                            .build());
    }
}
