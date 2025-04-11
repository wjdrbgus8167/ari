package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyArtistDashBoardResponse;
import com.ccc.ari.global.composition.service.mypage.GetMyArtistDashBoardService;
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
public class MyArtistDashBoardController {

    private final GetMyArtistDashBoardService getMyArtistDashBoardService;

    @GetMapping("/dashboard")
    public ApiUtils.ApiResponse<GetMyArtistDashBoardResponse> getMyArtistDashBoard(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {
        Integer memberId = memberUserDetails.getMemberId();

        GetMyArtistDashBoardResponse response = getMyArtistDashBoardService.getMyArtistDashBoard(memberId);

        return ApiUtils.success(response);
    }



}
