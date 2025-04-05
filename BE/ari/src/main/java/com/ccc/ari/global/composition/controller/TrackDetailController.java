package com.ccc.ari.global.composition.controller;

import com.ccc.ari.global.composition.response.TrackDetailResponse;
import com.ccc.ari.global.composition.service.TrackDetailService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

/*
    트랙 상세 페이지 조회 Controller
 */
@RestController
@RequiredArgsConstructor
public class TrackDetailController {

    private final TrackDetailService trackDetailService;

    @GetMapping("/api/v1/albums/{albumId}/tracks/{trackId}")
    public ApiUtils.ApiResponse<TrackDetailResponse> getTrackDetail(
            @PathVariable Integer albumId,
            @PathVariable Integer trackId,
            @AuthenticationPrincipal MemberUserDetails member) {

        // 로그인 여부에 따라 memberId를 Optional하게 처리
        Integer memberId = (member != null) ? member.getMemberId() : null;

        TrackDetailResponse response = trackDetailService.getTrackDetail(trackId,memberId);

        return ApiUtils.success(response);
    }
}
