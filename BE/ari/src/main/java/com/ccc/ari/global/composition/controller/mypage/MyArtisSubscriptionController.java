package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyArtistSubscriptionResponse;
import com.ccc.ari.global.composition.service.mypage.MyArtisSubscriptionService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/*
    내 아티스트 구독 목록 조회
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("api/v1/mypages")
public class MyArtisSubscriptionController {

    private final MyArtisSubscriptionService myArtisSubscriptionService;

    @GetMapping("/subscriptions/artists/list")
    public ApiUtils.ApiResponse<GetMyArtistSubscriptionResponse> getMyArtisSubscription(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
            ) {

        Integer memberId = memberUserDetails.getMemberId();

        GetMyArtistSubscriptionResponse response = myArtisSubscriptionService.getMyArtistSubscription(memberId);

        return ApiUtils.success(response);
    }

}
