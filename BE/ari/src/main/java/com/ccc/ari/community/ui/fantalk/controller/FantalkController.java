package com.ccc.ari.community.ui.fantalk.controller;

import com.ccc.ari.community.application.fantalk.command.CreateFantalkCommand;
import com.ccc.ari.community.application.fantalk.service.FantalkService;
import com.ccc.ari.community.ui.fantalk.request.CreateFantalkRequest;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/v1/fantalk-channels/{fantalkChannelId}/fantalks")
@RequiredArgsConstructor
public class FantalkController {

    private final FantalkService fantalkService;
    private final ObjectMapper objectMapper;

    /**
     * 팬톡 생성 API
     */
    @PostMapping
    public ApiUtils.ApiResponse<Void> createFantalk(
            @PathVariable Integer fantalkChannelId,
            @RequestPart(value = "fantalkImage", required = false) MultipartFile fantalkImage,
            @RequestPart(value = "request") String requestJson
    ) {
        try {
            MemberUserDetails userDetails = (MemberUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            Integer memberId = userDetails.getMemberId();

            // 1. JSON 문자열을 Request 객체로 변환합니다.
            CreateFantalkRequest request = objectMapper.readValue(requestJson, CreateFantalkRequest.class);

            // 2. Request 객체를 Command로 변환합니다.
            CreateFantalkCommand command = request.toCommand(memberId, fantalkChannelId, fantalkImage);

            // 3. 팬톡 생성 서비스를 호출합니다.
            fantalkService.createFantalk(command);

            return ApiUtils.success(null);
        } catch (IOException e) {
            return (ApiUtils.ApiResponse<Void>) ApiUtils.error(ErrorCode.S3_UPLOAD_ERROR);
        } catch (Exception e) {
            return (ApiUtils.ApiResponse<Void>) ApiUtils.error(ErrorCode.FANTALK_CREATION_FAILED);
        }
    }
}
