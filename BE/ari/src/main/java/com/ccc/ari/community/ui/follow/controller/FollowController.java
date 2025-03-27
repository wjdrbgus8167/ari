package com.ccc.ari.community.ui.follow.controller;

import com.ccc.ari.community.application.follow.service.FollowService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/follows/members/{memberId}")
@RequiredArgsConstructor
public class FollowController {

    private final FollowService followService;

    @PostMapping
    public ApiUtils.ApiResponse<Void> follow(@PathVariable Integer memberId) {
        MemberUserDetails userDetails = (MemberUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Integer followingId = userDetails.getMemberId();

        followService.follow(followingId, memberId);

        return ApiUtils.success(null);
    }

    @DeleteMapping
    public ApiUtils.ApiResponse<Void> unfollow(@PathVariable Integer memberId) {
        MemberUserDetails userDetails = (MemberUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        Integer followingId = userDetails.getMemberId();

        followService.unfollow(followingId, memberId);

        return ApiUtils.success(null);
    }
}
