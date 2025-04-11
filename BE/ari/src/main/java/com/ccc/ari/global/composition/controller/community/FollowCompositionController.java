package com.ccc.ari.global.composition.controller.community;

import com.ccc.ari.global.composition.response.community.FollowerListResponse;
import com.ccc.ari.global.composition.service.community.FollowListService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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
    public ApiUtils.ApiResponse<?> getFollowingList(
            @PathVariable Integer memberId,
            @AuthenticationPrincipal MemberUserDetails userDetails
    ) {

        Integer currentMemberId = userDetails.getMemberId();
        Object response = followListService.getFollowingList(memberId, currentMemberId);
        return ApiUtils.success(response);
    }

    @GetMapping("/follower/list")
    public ApiUtils.ApiResponse<FollowerListResponse> getFollowerList(@PathVariable Integer memberId) {

        FollowerListResponse response = followListService.getFollowerList(memberId);

        return ApiUtils.success(response);
    }
}
