package com.ccc.ari.global.composition.controller;

import com.ccc.ari.community.domain.fantalk.client.FantalkClient;
import com.ccc.ari.community.domain.fantalk.client.FantalkDto;
import com.ccc.ari.global.composition.response.FantalkListResponse;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 팬톡 목록 조회를 위한 Composition 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/fantalk-channels/{fantalkChannelId}/fantalks")
@RequiredArgsConstructor
public class FantalkCompositionController {

    private final FantalkClient fantalkClient;

    @GetMapping
    public ApiUtils.ApiResponse<FantalkListResponse> getFantalkList(@PathVariable Integer fantalkChannelId) {
        // 1. fantalkChannelId에 해당하는 팬톡 목록을 조회합니다.
        List<FantalkDto> fantalks = fantalkClient.getFantalksByChannelId(fantalkChannelId);

        // 2. 응답 데이터를 구성합니다.
        // TODO: 회원과 트랙 Client 구현 시 응답 데이터에 추가하겠습니다.
        FantalkListResponse response = FantalkListResponse.from(fantalks);

        return ApiUtils.success(response);
    }
}
