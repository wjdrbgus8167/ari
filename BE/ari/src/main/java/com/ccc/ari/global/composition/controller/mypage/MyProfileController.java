package com.ccc.ari.global.composition.controller.mypage;

import com.ccc.ari.global.composition.response.mypage.GetMyAlbumListResponse;
import com.ccc.ari.global.composition.response.mypage.MyProfileResponse;
import com.ccc.ari.global.composition.service.mypage.GetMyAlbumListService;
import com.ccc.ari.global.composition.service.mypage.MyProfileService;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.member.application.command.MyProfileUpdateCommand;
import com.ccc.ari.member.ui.response.MyProfileUpdateResponse;
import com.ccc.ari.member.ui.reuquest.MyProfileUpdateRequest;
import com.ccc.ari.music.ui.request.UploadAlbumRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;


@Slf4j
@RequiredArgsConstructor
@RestController
@RequestMapping("/api/v1/mypages")
public class MyProfileController {

    private final MyProfileService myProfileService;
    private final GetMyAlbumListService getMyAlbumListService;
    private final ObjectMapper objectMapper; //
    @GetMapping("/profile")
    ApiUtils.ApiResponse<MyProfileResponse> getMyProfile(
            @AuthenticationPrincipal MemberUserDetails member
    ){

        MyProfileResponse response = myProfileService.getMyProfile(member.getMemberId());

        return ApiUtils.success(response);
    }

    @PutMapping("/profile")
    public ApiUtils.ApiResponse<?> updateMyProfile(
            @AuthenticationPrincipal MemberUserDetails member,
            @RequestPart(value = "profile", required = true) String profile,
            @RequestPart(value = "profileImage", required = true) MultipartFile profileImage
    ) {
        try {

            MyProfileUpdateRequest request = objectMapper.readValue(profile, MyProfileUpdateRequest.class);
            log.info("닉네임: {}", request.getNickname());
            log.info("프로필이미지:{}",profileImage.getOriginalFilename());
            MyProfileUpdateCommand command = request.toCommand(profileImage, member.getMemberId());

            MyProfileUpdateResponse response = myProfileService.updateMyProfile(command);
            return ApiUtils.success(response);
        }catch (ApiException e){
            return ApiUtils.error(ErrorCode.PROFILE_UPLOAD_FAIL);
        } catch (Exception e) {
            log.error("프로필 수정 중 시스템 오류 발생", e);
            return ApiUtils.error(ErrorCode.PROFILE_UPLOAD_FAIL);
        }
    }

    @GetMapping("/mypages/albums")
    public ApiUtils.ApiResponse<List<GetMyAlbumListResponse>> getAlbums(
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ){

        return ApiUtils.success(getMyAlbumListService.getAlbumList(memberUserDetails.getMemberId(),memberUserDetails.getNickname()));
    }
}
