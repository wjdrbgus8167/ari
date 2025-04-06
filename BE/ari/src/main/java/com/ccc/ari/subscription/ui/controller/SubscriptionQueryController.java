package com.ccc.ari.subscription.ui.controller;

import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.subscription.application.service.SubscriptionQueryService;
import com.ccc.ari.subscription.application.command.GetMyRegularCyclesCommand;
import com.ccc.ari.subscription.application.response.GetMyRegularCyclesResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class SubscriptionQueryController {

    private final SubscriptionQueryService subscriptionQueryService;

    @GetMapping("/mypages/subscriptions/regular/list")
    public ApiUtils.ApiResponse<List<GetMyRegularCyclesResponse>> getMyRegularCycles(
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        List<GetMyRegularCyclesResponse> regularCycles = subscriptionQueryService.getRegularCycles(GetMyRegularCyclesCommand.builder()
                .memberId(userDetails.getMemberId())
                .build());

        return ApiUtils.success(regularCycles);
    }
}
