package com.ccc.ari.settlement.ui.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.settlement.application.command.GetMySettlementsForDateCommand;
import com.ccc.ari.settlement.application.response.GetSettlementResponse;
import com.ccc.ari.settlement.application.service.SettlementQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/mypages/settlements")
@RequiredArgsConstructor
public class SettlementQueryController {

    private final SettlementQueryService settlementQueryService;

    @GetMapping("/{year}/{month}/{day}")
    public ApiUtils.ApiResponse<GetSettlementResponse> getMySettlementsForDate(@AuthenticationPrincipal MemberUserDetails memberDetails,
                                                                               @PathVariable Integer year,
                                                                               @PathVariable Integer month,
                                                                               @PathVariable Integer day) {
        return ApiUtils.success(settlementQueryService.getRegularSettlementByArtistId(GetMySettlementsForDateCommand.builder()
                .artistId(memberDetails.getMemberId())
                .year(year)
                .month(month)
                .day(day)
                .build()));
    }

}
