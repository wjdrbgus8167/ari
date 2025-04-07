package com.ccc.ari.global.composition.service.artist;

import com.ccc.ari.community.domain.fantalk.client.FantalkChannelClient;
import com.ccc.ari.community.domain.fantalk.client.FantalkChannelDto;
import com.ccc.ari.community.domain.follow.client.FollowClient;
import com.ccc.ari.global.composition.response.artist.GetChannelInfoResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class GetChannelInfoService {

    private final FantalkChannelClient fantalkChannelClient;
    private final MemberClient memberClient;
    private final FollowClient followClient;
    private final SubscriptionPlanClient subscriptionPlanClient;
    private final SubscriptionClient subscriptionClient;

    public GetChannelInfoResponse getChannelInfo(Integer channelOwnerId, Integer currentMemberId) {
        FantalkChannelDto channelDto = fantalkChannelClient.getFantalkChannelByArtistId(channelOwnerId);
        MemberDto memberDto = memberClient.getMemberByMemberId(channelDto.getArtistId());

        Boolean followedYn = (channelOwnerId.equals(currentMemberId)) ||
                followClient.isFollowed(currentMemberId, channelOwnerId);

        int subscriberCount = 0;
        Optional<SubscriptionPlan> artistPlan = subscriptionPlanClient.getSubscriptionPlanByArtistId(channelOwnerId);

        if (artistPlan.isPresent()) {
            Integer planId = artistPlan.get().getSubscriptionPlanId().getValue();
            subscriberCount = subscriptionClient.countActiveSubscribersByPlanId(planId);
        }

        return GetChannelInfoResponse.builder()
                .fantalkChannelId(channelDto.getFantalkChannelId())
                .memberName(memberDto.getNickname())
                .profileImageUrl(memberDto.getProfileImageUrl())
                .subscriberCount(subscriberCount)
                .followedYn(followedYn)
                .build();
    }
}
