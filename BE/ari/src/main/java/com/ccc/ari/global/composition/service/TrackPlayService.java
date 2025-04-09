package com.ccc.ari.global.composition.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.event.StreamingEvent;
import com.ccc.ari.global.type.PlanType;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.client.GenreClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;

/**
1. subscription client -> member_id로 조회

2. subscription_cycle client -> subscription client 조회로 가져온 subscription_id로 구독 기간 조회
-> 기간 안쪽이면 인가

3. subscription_plan client -> subscription client 조회로 가져온 subscription_plan_id로 조회
    -> 이때 plan_type이  R이면 정기 구독이므로 모든 곡 허용
    -> 다른 PlanType이라면 현재 재생한 트랙의 곡을 subscription_plan에 있는 artist_id로 조회해서 비교 후
        현재 트랙이 이 아티스트의 곡이라면 인가(여기서 TrackClient 사용)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TrackPlayService {

    private final TrackClient trackClient;
    private final AlbumClient  albumClient;
    private final ApplicationEventPublisher eventPublisher;
    private final GenreClient genreClient;
    private final SubscriptionClient subscriptionClient;
    private final SubscriptionPlanClient subscriptionPlanClient;

    @Transactional
    public TrackPlayResponse trackPlay(TrackPlayCommand trackPlayCommand) {
        log.info("트랙재생을 시작합니다");
        TrackDto track = trackClient.getTrackByAlbumIdAndTrackId(trackPlayCommand.getAlbumId(),trackPlayCommand.getTrackId());
        AlbumDto album = albumClient.getAlbumById(trackPlayCommand.getAlbumId());
        GenreDto genre = genreClient.getGenre(album.getGenreName());

        Integer memberId = trackPlayCommand.getMemberId();

        // 구독 조회 후 인가
        boolean isAuthorized = false;

        // 만약 지금 트랙이 나의 앨범이면 그냥 스트리밍 인가
        if(albumClient.isMyAlbum(trackPlayCommand.getAlbumId(),memberId)) {
            log.info("나의 트랙은 인가");

            // 4. 나의 트랙은 스트리밍에 적용시키지 않음.
            return TrackPlayResponse.builder()
                    .artist(album.getArtist())
                    .coverImageUrl(album.getCoverImageUrl())
                    .lyrics(track.getLyrics())
                    .tackFileUrl(track.getTrackFileUrl())
                    .title(track.getTitle())
                    .build();
        }else{

            // 모든 구독 정보 조회
            List<Subscription> subscriptions = subscriptionClient.getSubscriptionInfo(trackPlayCommand.getMemberId())
                    .orElseThrow(()-> new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND));
            // 현재 가지고 있는 구독권 조회
            for (Subscription subscription : subscriptions) {

                // 구독권이 현재 활성화 상태이고 만료되지 않았다면
                if (subscription.isActivateYn() && subscription.getExpiredAt() == null) {
                    log.info("현재 유효한 구독권입니다: subscriptionPlanId = {}", subscription.getSubscriptionPlanId());
                } else {
                    log.info("비활성화된 구독권이거나 만료된 구독권입니다. ID = {}", subscription.getSubscriptionPlanId());
                    continue;
                }

                SubscriptionPlan plan;
                try {
                    plan = subscriptionPlanClient.getSubscriptionPlan(subscription.getSubscriptionPlanId());
                    log.info("구독권 정보 조회 성공 → 타입: {}, planId: {}", plan.getPlanType(), plan.getSubscriptionPlanId());
                } catch (ApiException e) {
                    log.warn("구독권 조회 실패 subscriptionPlanId: {}", subscription.getSubscriptionPlanId(), e);
                    continue; // 실패한 구독권은 skip
                }

                // 정기 구독일 경우 무조건 허용
                if (plan.getPlanType() == PlanType.R) {
                    isAuthorized = true;
                    log.info("정기 구독으로 인가 허용됨.");
                    break;
                }

                // 아티스트 구독일 경우, 현재 트랙의 아티스트와 비교
                if (plan.getPlanType() == PlanType.A) {
                    if (plan.getArtistId().equals(album.getMemberId())) {
                        isAuthorized = true;
                        log.info("아티스트 구독으로 인가 허용됨. 아티스트 ID: {}", plan.getArtistId());
                        break;
                    } else {
                        log.info("아티스트 구독이지만 아티스트 ID 불일치. 구독 아티스트: {}, 트랙 아티스트: {}",
                                plan.getArtistId(), album.getMemberId());
                    }
                }
            }
        }


        // 구독 인가X
        if (!isAuthorized) {
            throw  new ApiException(ErrorCode.SUBSCRIPTION_ACCESS_DENIED);
        }

        // 3. 스트리밍 이벤트 발행
        StreamingEvent event = StreamingEvent.builder()
                .memberId(trackPlayCommand.getMemberId())
                .nickname(trackPlayCommand.getNickname())
                .trackId(track.getTrackId())
                .trackTitle(track.getTitle())
                .artistId(album.getMemberId())
                .artistName(album.getArtist())
                .albumId(album.getAlbumId())
                .albumTitle(album.getTitle())
                .genreId(genre.getGenreId())
                .genreName(genre.getGenreName())
                .timestamp(Instant.now())
                .build();

        eventPublisher.publishEvent(event);
        log.info("이벤트 발행 완료 - 트랙: {}, 유저: {}", event.getTrackTitle(), event.getNickname());

        // 4. 응답 반환
        return TrackPlayResponse.builder()
                .artist(album.getArtist())
                .coverImageUrl(album.getCoverImageUrl())
                .lyrics(track.getLyrics())
                .tackFileUrl(track.getTrackFileUrl())
                .title(track.getTitle())
                .build();
    }
}
