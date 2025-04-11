package com.ccc.ari.settlement.ui.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.settlement.application.response.WalletStatusResponse;
import com.ccc.ari.settlement.application.service.WalletStatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/mypages/wallet")
@RequiredArgsConstructor
public class WalletController {

    private final WalletStatusService walletStatusService;

    @GetMapping
    public ApiUtils.ApiResponse<WalletStatusResponse> getWalletStatus(
            @AuthenticationPrincipal MemberUserDetails userDetails
    ) {
        Integer memberId = userDetails.getMemberId();
        WalletStatusResponse response = walletStatusService.getWalletStatus(memberId);
        return ApiUtils.success(response);
    }
}
