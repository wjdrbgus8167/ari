package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMySubscriptionListResponse;
import com.ccc.ari.global.composition.service.mypage.GetMySubscriptionListService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/mypages")
public class MySubscriptionListController {

    private final GetMySubscriptionListService getMySubscriptionListService;
    @GetMapping("/subscriptions/list")
    public ApiUtils.ApiResponse<GetMySubscriptionListResponse> getMySubscriptionList(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ){
        Integer memberId = memberUserDetails.getMemberId();

        GetMySubscriptionListResponse response = getMySubscriptionListService.getMySubscriptionList(memberId);

        return ApiUtils.success(response);
    }
}
