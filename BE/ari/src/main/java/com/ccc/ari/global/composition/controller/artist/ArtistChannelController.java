package com.ccc.ari.global.composition.controller.artist;

import com.ccc.ari.global.composition.response.artist.GetChannelInfoResponse;
import com.ccc.ari.global.composition.service.artist.GetChannelInfoService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ArtistChannelController {

    private final GetChannelInfoService getChannelInfoService;

    @GetMapping("/members/{memberId}/channel-info")
    public ApiUtils.ApiResponse<GetChannelInfoResponse> getChannelInfo(
            @PathVariable Integer memberId,
            @AuthenticationPrincipal MemberUserDetails userDetails
    ) {
        Integer currentMemberId = userDetails.getMemberId();
        GetChannelInfoResponse response = getChannelInfoService.getChannelInfo(memberId, currentMemberId);
        return ApiUtils.success(response);
    }
}
