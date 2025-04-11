package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyTrackListResponse;
import com.ccc.ari.global.composition.service.mypage.MyTrackListService;
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

public class MyTrackListController {

    private final MyTrackListService myTrackListService;

    @GetMapping("/tracks/list")
    public ApiUtils.ApiResponse<GetMyTrackListResponse> getMyTrackList(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails){

        Integer memberId = memberUserDetails.getMemberId();
        GetMyTrackListResponse response = myTrackListService.getMyTrackList(memberId);


        return ApiUtils.success(response);
    }
}
