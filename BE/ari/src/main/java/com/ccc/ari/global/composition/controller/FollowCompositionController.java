package com.ccc.ari.global.composition.controller;

import com.ccc.ari.global.composition.response.FollowerListResponse;
import com.ccc.ari.global.composition.response.FollowingListResponse;
import com.ccc.ari.global.composition.service.FollowListService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/follows/members/{memberId}")
@RequiredArgsConstructor
public class FollowCompositionController {

    private final FollowListService followListService;

    @GetMapping("/following/list")
    public ApiUtils.ApiResponse<FollowingListResponse> getFollowingList(@PathVariable Integer memberId) {

        FollowingListResponse response = followListService.getFollowingList(memberId);

        return ApiUtils.success(response);
    }

    @GetMapping("/follower/list")
    public ApiUtils.ApiResponse<FollowerListResponse> getFollowerList(@PathVariable Integer memberId) {

        FollowerListResponse response = followListService.getFollowerList(memberId);

        return ApiUtils.success(response);
    }
}
