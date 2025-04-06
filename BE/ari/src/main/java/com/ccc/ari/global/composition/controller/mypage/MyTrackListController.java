package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyTrackListResponse;
import com.ccc.ari.global.composition.service.mypage.MyTrackListService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/mypage")

public class MyTrackListController {

    private final MyTrackListService myTrackListService;

    @GetMapping("/tracks/list")
    public ApiUtils.ApiResponse<List<GetMyTrackListResponse>> getMyTrackList(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails) throws ExecutionException, InterruptedException {

        Integer memberId = memberUserDetails.getMemberId();
        CompletableFuture<List<GetMyTrackListResponse>> futureTracks = myTrackListService.getArtistTrackStreamingData(memberId);

        // CompletableFuture의 결과를 기다려서 받음
        List<GetMyTrackListResponse> response = futureTracks.get();

        return ApiUtils.success(response);
    }
}
