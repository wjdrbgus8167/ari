package com.ccc.ari.community.ui.rating.controller;

import com.ccc.ari.community.application.rating.commad.CreateAlbumRatingCommand;
import com.ccc.ari.community.application.rating.service.RatingService;
import com.ccc.ari.community.ui.rating.request.CreatAlbumRatingRequest;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/albums")
@RequiredArgsConstructor
@Slf4j
public class AlbumRatingController {

    private final RatingService ratingService;

    @PostMapping("/{albumId}/ratings")
    public ApiUtils.ApiResponse<?> createRating(
            @PathVariable Integer albumId,
            @RequestBody CreatAlbumRatingRequest request,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails) {

        CreateAlbumRatingCommand command  = request.toCommand(memberUserDetails.getMemberId(),albumId);

        ratingService.creatRating(command);

        return ApiUtils.success("평점이 등록되었습니다.");
    }

}
