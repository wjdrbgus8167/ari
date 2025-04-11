package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.community.domain.follow.client.FollowClient;
import com.ccc.ari.community.domain.follow.client.FollowerDto;
import com.ccc.ari.global.composition.response.mypage.MyProfileResponse;
import com.ccc.ari.global.infrastructure.S3ClientImpl;
import com.ccc.ari.member.application.command.MyProfileUpdateCommand;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.mapper.MemberMapper;
import com.ccc.ari.member.ui.response.MyProfileUpdateResponse;
import com.ccc.ari.member.ui.reuquest.MyProfileUpdateRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

@Component
@RequiredArgsConstructor
public class MyProfileService {

    private final MemberClient memberClient;
    private final FollowClient followClient;
    private final S3ClientImpl s3Client;
    private final MemberMapper memberMapper;

    public MyProfileResponse getMyProfile(Integer memberId) {

        MemberDto member = memberClient.getMemberByMemberId(memberId);
        Integer followerCount = followClient.countFollowersByMemberId(memberId);
        Integer followingCount = followClient.countFollowingsByMemberId(memberId);

        return MyProfileResponse.builder()
                .memberId(memberId)
                .nickName(member.getNickname())
                .bio(member.getBio())
                .profileImageUrl(member.getProfileImageUrl())
                .instagram(member.getInstagramId())
                .followerCount(followerCount)
                .followingCount(followingCount)
                .build();
    }

    @Transactional
    public MyProfileUpdateResponse updateMyProfile(MyProfileUpdateCommand command) {

        // 영속성 있는 MemberEntity 조회 (반드시 Repository 사용!)
        MemberEntity member = memberClient.getMemberEntityByMemberId(command.getMemberId());

        // 기존 프로필 이미지 유지
        String imageUrl = member.getProfileImageUrl();

        // 이미지가 있다면 업로드 후 URL 교체
        if (command.getProfileImage() != null && !command.getProfileImage().isEmpty()) {
            imageUrl = s3Client.uploadImage(command.getProfileImage(), "mypages");
        }

        // 실제 영속 객체에 업데이트
        member.updateProfile(command.getNickname(), command.getBio(), imageUrl, command.getInstagramId());

        // 응답 생성 (member는 이미 업데이트 되어 있음)
        return MyProfileUpdateResponse.builder()
                .nickname(member.getNickname())
                .bio(member.getBio())
                .profileImageUrl(member.getProfileImageUrl())
                .instagramId(member.getInstagramId())
                .build();
    }


}
