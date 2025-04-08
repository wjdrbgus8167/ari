package com.ccc.ari.global.composition.controller.mypage;


import com.ccc.ari.global.composition.response.mypage.GetMyRegularSubscriptionDetailResponse;
import com.ccc.ari.global.composition.service.mypage.MyRegularSubscriptionDetailService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/v1/mypages")
public class MyRegularSubscriptionDetailController {

    private final MyRegularSubscriptionDetailService myRegularSubscriptionDetailService;

    @GetMapping("/subscriptions/regular/detail/{cycleId}")
    public ApiUtils.ApiResponse<GetMyRegularSubscriptionDetailResponse> myRegularSubscriptionDetail(
            @PathVariable Integer cycleId,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
            ){

        Integer memberId = memberUserDetails.getMemberId();

        GetMyRegularSubscriptionDetailResponse response =
                myRegularSubscriptionDetailService.getMyRegularSubscriptionDetail(cycleId,memberId);

        return ApiUtils.success(response);
    }
}
