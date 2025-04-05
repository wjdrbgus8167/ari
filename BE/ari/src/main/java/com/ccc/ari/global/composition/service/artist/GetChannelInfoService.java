package com.ccc.ari.global.composition.service.artist;

import com.ccc.ari.community.domain.fantalk.client.FantalkChannelClient;
import com.ccc.ari.community.domain.fantalk.client.FantalkChannelDto;
import com.ccc.ari.community.domain.follow.client.FollowClient;
import com.ccc.ari.global.composition.response.artist.GetChannelInfoResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GetChannelInfoService {

    private final FantalkChannelClient fantalkChannelClient;
    private final MemberClient memberClient;
    private final FollowClient followClient;

    public GetChannelInfoResponse getChannelInfo(Integer channelOwnerId, Integer currentMemberId) {
        FantalkChannelDto channelDto = fantalkChannelClient.getFantalkChannelByArtistId(channelOwnerId);
        MemberDto memberDto = memberClient.getMemberByMemberId(channelDto.getArtistId());

        Boolean followedYn;
        if (channelOwnerId == currentMemberId) {
            followedYn = true;
        } else {
            followedYn = followClient.isFollowed(currentMemberId, channelOwnerId);
        }

        // TODO: 구독자 수 더미 데이터 수정 필요
        return GetChannelInfoResponse.builder()
                .fantalkChannelId(channelDto.getFantalkChannelId())
                .memberName(memberDto.getNickname())
                .profileImageUrl(memberDto.getProfileImageUrl())
                .subscriberCount(0)
                .followedYn(followedYn)
                .build();
    }
}
