package com.ccc.ari.global.composition.service.community;

import com.ccc.ari.community.domain.fantalk.client.FantalkChannelClient;
import com.ccc.ari.community.domain.fantalk.client.FantalkClient;
import com.ccc.ari.community.domain.fantalk.client.FantalkDto;
import com.ccc.ari.global.composition.response.community.FantalkListResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionCompositionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class FantalkListService {

    private final FantalkClient fantalkClient;
    private final MemberClient memberClient;
    private final TrackClient trackClient;
    private final AlbumClient albumClient;
    private final FantalkChannelClient fantalkChannelClient;
    private final SubscriptionPlanClient subscriptionPlanClient;
    private final SubscriptionCompositionClient subscriptionCompositionClient;

    public FantalkListResponse getFantalkList(Integer fantalkChannelId, Integer currentMemberId) {
        // 1. fantalkChannelId에 해당하는 팬톡 목록을 조회합니다.
        List<FantalkDto> fantalks = fantalkClient.getFantalksByChannelId(fantalkChannelId);
        Integer channelOwnerId = fantalkChannelClient.getFantalkChannelById(fantalkChannelId).getArtistId();

        // 2. 팬톡 작성자 정보를 조회합니다.
        // TODO: N+1 문제 해결
        Map<Integer, MemberDto> memberMap = new HashMap<>();
        for (FantalkDto fantalk : fantalks) {
            Integer memberId = fantalk.getMemberId();
            if (!memberMap.containsKey(memberId)) {
                MemberDto member = memberClient.getMemberByMemberId(memberId);
                memberMap.put(memberId, member);
            }
        }

        // 3. 연결된 트랙 정보를 조회합니다.
        Map<Integer, TrackDto> trackMap = new HashMap<>();
        Map<Integer, AlbumDto> albumMap = new HashMap<>();

        for (FantalkDto fantalk : fantalks) {
            Integer trackId = fantalk.getTrackId();
            if (trackId != null && !trackMap.containsKey(trackId)) {
                TrackDto track = trackClient.getTrackById(trackId);
                trackMap.put(trackId, track);

                Integer albumId = track.getAlbumId();
                if (albumId != null && !albumMap.containsKey(albumId)) {
                    AlbumDto album = albumClient.getAlbumById(albumId);
                    albumMap.put(albumId, album);
                }
            }
        }

        // 4. 구독 상태를 확인합니다.
        boolean subscribedYn = false;
        if (channelOwnerId.equals(currentMemberId)) {
            subscribedYn = true;
        } else {
            Optional<SubscriptionPlan> artistPlan = subscriptionPlanClient.getSubscriptionPlanByArtistId(channelOwnerId);

            if (artistPlan.isPresent()) {
                Integer planId = artistPlan.get().getSubscriptionPlanId().getValue();
                subscribedYn = subscriptionCompositionClient.hasActiveSubscription(currentMemberId, planId);
            }
        }

        // 5. 응답 데이터를 구성합니다.
        return FantalkListResponse.from(fantalks, memberMap, trackMap, albumMap, subscribedYn);
    }
}
