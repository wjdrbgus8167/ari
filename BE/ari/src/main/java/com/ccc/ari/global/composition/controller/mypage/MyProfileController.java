package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyAlbumListResponse;
import com.ccc.ari.global.composition.response.mypage.MyProfileResponse;
import com.ccc.ari.global.composition.service.mypage.GetMyAlbumListService;
import com.ccc.ari.global.composition.service.mypage.MyProfileService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/v1/mypages")
public class MyProfileController {

    private final MyProfileService myProfileService;
    private final GetMyAlbumListService getMyAlbumListService;
    private
    @GetMapping("/profile")
    ApiUtils.ApiResponse<MyProfileResponse> getMyProfile(
            @AuthenticationPrincipal MemberUserDetails member
    ){

        MyProfileResponse response = myProfileService.getMyProfile(member.getMemberId());

        return ApiUtils.success(response);
    }

    @GetMapping("/mypages/albums")
    public ApiUtils.ApiResponse<List<GetMyAlbumListResponse>> getAlbums(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ){

        return ApiUtils.success(getMyAlbumListService.getAlbumList(memberUserDetails.getMemberId(),memberUserDetails.getNickname()));
    }
}
