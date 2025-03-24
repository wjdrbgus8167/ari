package com.ccc.ari.community.ui.fantalk.controller;

import com.ccc.ari.community.application.fantalk.command.CreateFantalkCommand;
import com.ccc.ari.community.application.fantalk.service.FantalkService;
import com.ccc.ari.community.ui.fantalk.request.CreateFantalkRequest;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/fantalk-channels/{fantalkChannelId}/fantalks")
@RequiredArgsConstructor
public class FantalkController {

    private final FantalkService fantalkService;

    /**
     * 팬톡 생성 API
     */
    @PostMapping
    public ApiUtils.ApiResponse<Void> createFantalk(
            @PathVariable Integer fantalkChannelId,
            @RequestBody CreateFantalkRequest request
    ) {
        // TODO: 인증 구현 완료 시 수정하겠습니다.
        Integer memberId = 1;

        // Request -> Command 변환
        CreateFantalkCommand command = request.toCommand(memberId, fantalkChannelId);

        fantalkService.createFantalk(command);

        return ApiUtils.success(null);
    }
}
