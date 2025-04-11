package com.ccc.ari.global.composition.controller.community;

import com.ccc.ari.global.composition.response.community.FantalkListResponse;
import com.ccc.ari.global.composition.service.community.FantalkListService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 팬톡 목록 조회를 위한 Composition 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/fantalk-channels/{fantalkChannelId}/fantalks")
@RequiredArgsConstructor
public class FantalkCompositionController {

    private final FantalkListService fantalkListService;

    @GetMapping
    public ApiUtils.ApiResponse<FantalkListResponse> getFantalkList(
            @PathVariable Integer fantalkChannelId,
            @AuthenticationPrincipal MemberUserDetails userDetails
    ) {

        Integer memberId = userDetails.getMemberId();;
        FantalkListResponse response = fantalkListService.getFantalkList(fantalkChannelId, memberId);
        return ApiUtils.success(response);
    }
}
