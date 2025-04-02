package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.MyProfileResponse;
import com.ccc.ari.global.composition.service.mypage.MyProfileService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/v1")
public class MyProfileController {

    private final MyProfileService myProfileService;

    @GetMapping("/mypages/profile")
    ApiUtils.ApiResponse<MyProfileResponse> getMyProfile(
            @AuthenticationPrincipal MemberUserDetails member
    ){

        MyProfileResponse response = myProfileService.getMyProfile(member.getMemberId());

        return ApiUtils.success(response);
    }
}
