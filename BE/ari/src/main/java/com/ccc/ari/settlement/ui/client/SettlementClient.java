package com.ccc.ari.settlement.ui.client;

import com.ccc.ari.settlement.application.command.GetMyRegularSettlementDetailCommand;
import com.ccc.ari.settlement.application.response.GetArtistDailySettlementResponse;
import com.ccc.ari.settlement.application.response.RegularSettlementDetailResponse;
import com.ccc.ari.settlement.application.service.SettlementQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SettlementClient {

    private final SettlementQueryService settlementQueryService;

    /**
     * 특정 사용자의 특정 구독 사이클에 대한 정산 세부사항을 조회합니다.
     * 세부사항은 아티스트 별 스트리밍 수와 정산 금액입니다.
     */
    public RegularSettlementDetailResponse getMyRegularSettlementDetail(Integer subscriberId,
                                                                        Integer cycleId) {
        return settlementQueryService.getMyRegularSettlementDetail(GetMyRegularSettlementDetailCommand.builder()
                                                                            .subscriberId(subscriberId)
                                                                            .cycleId(cycleId)
                                                                            .build());
    }

    /**
     * 특정 아티스트의 일간 정산 내역과 오늘의 정산 및 어제와의 정산 금액 차이를 조회합니다.
     */
    public GetArtistDailySettlementResponse getArtistDailySettlement(Integer artistId) {
        return settlementQueryService.getArtistDailySettlement(artistId);
    }

    /**
     * 특정 사용자의 특정 아티스트에 대한 각 구독 사이클의 정산 금액을 조회합니다.
     */

}
