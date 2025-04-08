package com.ccc.ari.global.composition.controller.like;

import com.ccc.ari.global.composition.response.community.LikeAlbumListResponse;
import com.ccc.ari.global.composition.response.community.LikeTrackListResponse;
import com.ccc.ari.global.composition.service.like.GetLikeListService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/likes")
@RequiredArgsConstructor
public class LikeListCompositionController {

    private final GetLikeListService getLikeListService;

    @GetMapping("/albums")
    public ApiUtils.ApiResponse<LikeAlbumListResponse> getLikeAlbumList(
            @AuthenticationPrincipal MemberUserDetails userDetails
    ) {
        Integer memberId = userDetails.getMemberId();
        LikeAlbumListResponse response = getLikeListService.getLikeAlbumList(memberId);
        return ApiUtils.success(response);
    }

    @GetMapping("/tracks")
    public ApiUtils.ApiResponse<LikeTrackListResponse> getLikeTrackList(
            @AuthenticationPrincipal MemberUserDetails userDetails
    ) {
        Integer memberId = userDetails.getMemberId();
        LikeTrackListResponse response = getLikeListService.getLikeTrackList(memberId);
        return ApiUtils.success(response);
    }
}
