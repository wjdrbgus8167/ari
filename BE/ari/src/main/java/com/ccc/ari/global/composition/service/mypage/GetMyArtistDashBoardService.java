package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.aggregation.ui.client.StreamingCountClient;
import com.ccc.ari.aggregation.ui.response.GetArtistTrackCountListResponse;
import com.ccc.ari.aggregation.ui.response.GetListenerAggregationResponse;
import com.ccc.ari.aggregation.ui.response.TrackCountResult;
import com.ccc.ari.chart.application.repository.ChartRepository;
import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.domain.entity.StreamingWindow;
import com.ccc.ari.chart.domain.vo.ChartEntry;
import com.ccc.ari.chart.domain.vo.HourlyStreamCount;
import com.ccc.ari.chart.infrastructure.repository.RedisWindowRepository;
import com.ccc.ari.global.composition.response.mypage.GetMyArtistDashBoardResponse;
import com.ccc.ari.global.composition.response.mypage.GetMyTrackListResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Service;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class GetMyArtistDashBoardService {

    private final SubscriptionClient subscriptionClient;
    private final SubscriptionPlanClient  subscriptionPlanClient;
    private final AlbumClient albumClient;
    private final StreamingCountClient streamingCountClient;
    private final TrackClient trackClient;
    private final ChartRepository chartRepository;
    private final RedisWindowRepository redisWindowRepository;

    public GetMyArtistDashBoardResponse getMyArtistDashBoard(Integer memberId) {

        // 아티스트 앨범 리스트 조회
        List<AlbumEntity> albumDtoList = albumClient.getAllAlbums(memberId);

        // 현재 아티스트의 구독 플랜 조회
        SubscriptionPlan subscriptionPlan = subscriptionPlanClient.getSubscriptionPlanByArtistId(memberId);
        if(subscriptionPlan == null) {
            throw  new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND);
        }

        log.info("구독Plan 아티스트ID:{}", subscriptionPlan.getArtistId());

        // 아티스트의 구독 Plan ID 가져오기
        Integer subscriptionPlanId = subscriptionPlan.getSubscriptionPlanId().getValue();
        log.info("구독Plan ID:{}", subscriptionPlanId);

        // 비동기 처리: 스트리밍 데이터 조회
        CompletableFuture<GetArtistTrackCountListResponse> streamingFuture =
                CompletableFuture.supplyAsync(() -> streamingCountClient.getArtistTrackCounts(memberId));

        // 동기 처리: 구독자 수 조회
        Integer subscriberCount = subscriptionClient
                .getSubscriptionBySubscriptionPlanId(subscriptionPlanId).size();


        // 이번 달 구독 시작 시간/끝 시간 계산
        LocalDateTime startOfMonth = YearMonth.now().atDay(1).atStartOfDay();
        LocalDateTime endOfMonth = YearMonth.now().atEndOfMonth().atTime(23, 59, 59, 999_999_999);
        log.info("이번 달 구독 시작 시간:{}",startOfMonth);
        log.info("이번 달 구독 종료 시간:{}",endOfMonth);

        // 오늘 하루 구독자 수
        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = LocalDate.now().atTime(23, 59, 59, 999_999_999);

        // 오늘 하루 신규 구독자 수
        Integer todayNewSubscribeCount =
                subscriptionClient.getRegularSubscription(subscriptionPlanId,startOfToday,endOfToday).size();

        // 이번 달 신규 구독자 수
        Integer thisMonthNewSubscriberCount = subscriptionClient
                .getRegularSubscription(subscriptionPlanId, startOfMonth, endOfMonth).size();

        log.info("이번달 신규 구독자 수 :{}", thisMonthNewSubscriberCount);

        // 아티스트 전달 스트리밍 수
        Integer prevMonthStreamingCount = getPreviousMonthStreamingCountByArtist(memberId);

        log.info("아티스트 전달 스트리밍 수:{}", prevMonthStreamingCount);

        // 비동기 결과 가져오기
        GetArtistTrackCountListResponse streaming;
        try {
            streaming = streamingFuture.join();
        } catch (Exception e) {
            log.error("비동기 스트리밍 데이터 조회 중 오류 발생", e);
            throw new ApiException(ErrorCode.SUBSCRIPTION_NOT_FOUND); // 예외 정의 필요
        }

        log.info("트랙 ID:{}",streaming.getTrackCountList().size());
        if(streaming.getTrackCountList().size() > 0){

            for(int i=0;i<streaming.getTrackCountList().size();i++){

                log.info("트랙 ID:{}",streaming.getTrackCountList().get(i).getTrackId());
                log.info("트랙 스트리밍 횟수:{}",streaming.getTrackCountList().get(i).getTotalCount());

            }
        }

        // 이번 달 스트리밍 횟수
        int thisMonthStreamingCount = streaming.getTrackCountList().stream()
                .mapToInt(TrackCountResult::getMonthCount)
                .sum();

        // 이번 달 스트리밍 횟수 - 전 달 스트리밍 힛수
        int streamingDiff = thisMonthStreamingCount - prevMonthStreamingCount;

        // 아티스트 앨범 목록 조회
        List<GetMyArtistDashBoardResponse.MyArtistAlbum> albums =
                albumDtoList.stream().map(albumEntity -> {
                    return GetMyArtistDashBoardResponse.MyArtistAlbum.builder()
                            .albumTitle(albumEntity.getAlbumTitle())
                            .coverImageUrl(albumEntity.getCoverImageUrl())
                            .trackCount(trackClient.getTracksByAlbumId(albumEntity.getAlbumId()).size())
                            .build();
                }).toList();

        // 전체 스트리밍 횟수
        int totalStreamingCount = streaming.getTrackCountList().stream()
                .mapToInt(TrackCountResult::getTotalCount)
                .sum();

        // 이전 달의 마지막 날 계산
        LocalDateTime endOfPreviousMonth = YearMonth.now().minusMonths(1)
                .atEndOfMonth().atTime(23, 59, 59, 999_999_999);
        LocalDateTime startofTime =YearMonth.of(2025, 3).atDay(1).atStartOfDay();;

        // 이전 달 말까지의 구독자 수 가져오기
        Integer subscribersUntilPreviousMonth = subscriptionClient
                .getRegularSubscription(subscriptionPlanId,startofTime, endOfPreviousMonth).size();


        // 현재 구독자 수와 이전 달까지의 구독자 수 차이 계산
        Integer newSubscriberDiff = subscriberCount - subscribersUntilPreviousMonth;
        /**
         * 월별 구독자 수와 일별 구독자 수 계산 로직
         */
        List<GetMyArtistDashBoardResponse.MonthlySubscriberCount> monthlySubscriberCounts = new ArrayList<>();
        List<GetMyArtistDashBoardResponse.DailySubscriberCount> dailySubscriberCounts = new ArrayList<>();

        LocalDate now = LocalDate.now();

        // 1. 월별 구독자 수 (25.03 ~ 25.04)
        YearMonth startMonth = YearMonth.of(2025, 3);
        YearMonth currentMonth = YearMonth.from(now);

        YearMonth tempMonth = startMonth;

        while (!tempMonth.isAfter(currentMonth)) {
            LocalDateTime start = tempMonth.atDay(1).atStartOfDay();
            LocalDateTime end = tempMonth.atEndOfMonth().atTime(23, 59, 59, 999_999_999);

            int count = subscriptionClient.getRegularSubscription(subscriptionPlanId, start, end).size();

            monthlySubscriberCounts.add(GetMyArtistDashBoardResponse.MonthlySubscriberCount
                    .builder()
                    .month(tempMonth.format(DateTimeFormatter.ofPattern("yy.MM")))
                    .subscriberCount(count)
                    .build());

            tempMonth = tempMonth.plusMonths(1);
        }

        // 2. 일별 구독자 수 (25.04.01 ~ 오늘)
        LocalDate firstDayOfThisMonth = now.withDayOfMonth(1);
        LocalDate today = now;

        for (LocalDate date = firstDayOfThisMonth; !date.isAfter(today); date = date.plusDays(1)) {
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.atTime(23, 59, 59, 999_999_999);

            int count = subscriptionClient.getRegularSubscription(subscriptionPlanId, start, end).size();

            dailySubscriberCounts.add(GetMyArtistDashBoardResponse.DailySubscriberCount
                    .builder()
                    .date(date.toString())
                    .subscriberCount(count)
                    .build());
        }

        return GetMyArtistDashBoardResponse.builder()
                .subscriberCount(subscriberCount)
                .totalStreamingCount(totalStreamingCount)
                .thisMonthStreamingCount(thisMonthStreamingCount)
                // 이번 달 - 전 달
                .streamingDiff(streamingDiff)
                // 이번 달 구독자 수
                .thisMonthNewSubscriberCount(thisMonthNewSubscriberCount)
                .albums(albums)
                .monthlySettlement(null)
                .walletAddress(null)
                .newSubscriberDiff(newSubscriberDiff)
                .settlementDiff(null)
                .dailySubscriberCounts(dailySubscriberCounts)
                .monthlySubscriberCounts(monthlySubscriberCounts)
                .todayStreamingCount(null)
                .todayNewSubscribeCount(todayNewSubscribeCount)
                .build();
    }

    // 전월 아티스트 스트리밍 횟수 가져오는 로직
    public Integer getPreviousMonthStreamingCountByArtist(Integer memberId) {
        // 아티스트의 앨범과 트랙 가져오기
        List<AlbumDto> albumDtoList = albumClient.getAllAlbumsByMember(memberId);

        log.info("앨범 리스트 조회: {}", albumDtoList.size());

        if (albumDtoList.isEmpty()) {
            log.warn("앨범이 없는 아티스트입니다. memberId: {}", memberId);
            return 0;
        }

        List<Integer> trackIds = new ArrayList<>();
        for (AlbumDto album : albumDtoList) {
            List<TrackDto> tracks = trackClient.getTracksByAlbumId(album.getAlbumId());
            if (tracks != null && !tracks.isEmpty()) {
                trackIds.addAll(tracks.stream()
                        .map(TrackDto::getTrackId)
                        .collect(Collectors.toList()));
            }
        }

        log.info("트랙 리스트 조회: {}", trackIds.size());

        if (trackIds.isEmpty()) {
            log.warn("트랙이 없는 아티스트입니다. memberId: {}", memberId);
            return 0;
        }

        // Redis에서 모든 트랙 윈도우 가져오기
        Map<Integer, StreamingWindow> allTrackWindows = redisWindowRepository.getAllTracksWindows();

        // 전달 계산 (현재 달에서 1을 빼서 계산)
        YearMonth previousMonth = YearMonth.now().minusMonths(1);
        int prevYear = previousMonth.getYear();
        int prevMonthValue = previousMonth.getMonthValue();

        log.info("검색할 전달: {}-{}", prevYear, prevMonthValue);

        // 전체 카운트를 저장할 변수
        int totalCount = 0;

        // 각 트랙별로 처리
        for (Integer trackId : trackIds) {
            StreamingWindow window = allTrackWindows.get(trackId);
            if (window == null) {
                log.warn("트랙 ID {}에 대한 StreamingWindow가 없습니다.", trackId);
                continue;
            }

            // 해당 트랙의 이번 달 스트리밍 카운트 계산
            int trackCount = 0;
            List<HourlyStreamCount> hourlyCounts = window.getHourlyCounts();

            if (hourlyCounts != null) {
                for (HourlyStreamCount count : hourlyCounts) {
                    if (count != null && count.getTimestamp() != null) {
                        // Object 타입 확인
                        Object timestamp = count.getTimestamp();
                        log.debug("타임스탬프 클래스: {}", timestamp.getClass().getName());

                        // 타임스탬프 타입에 따라 다르게 처리
                        int year = 0;
                        int month = 0;

                        if (timestamp instanceof LocalDateTime) {
                            LocalDateTime dateTime = (LocalDateTime) timestamp;
                            year = dateTime.getYear();
                            month = dateTime.getMonthValue();
                        } else if (timestamp instanceof Instant) {
                            Instant instant = (Instant) timestamp;
                            LocalDateTime dateTime = LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
                            year = dateTime.getYear();
                            month = dateTime.getMonthValue();
                        } else if (timestamp instanceof Long) {
                            // Epoch 밀리초로 가정
                            Instant instant = Instant.ofEpochMilli((Long) timestamp);
                            LocalDateTime dateTime = LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
                            year = dateTime.getYear();
                            month = dateTime.getMonthValue();
                        } else if (timestamp instanceof String) {
                            // ISO 형식의 문자열로 가정
                            try {
                                LocalDateTime dateTime = LocalDateTime.parse((String) timestamp);
                                year = dateTime.getYear();
                                month = dateTime.getMonthValue();
                            } catch (Exception e) {
                                log.warn("타임스탬프 파싱 실패: {}", timestamp);
                                continue;
                            }
                        } else {
                            log.warn("지원하지 않는 타임스탬프 형식: {}", timestamp.getClass().getName());
                            continue;
                        }

                        log.debug("파싱된 날짜: {}-{}, 필터링 날짜: {}-{}",
                                year, month, prevYear, prevMonthValue);

                        // 연도와 월이 전달과 일치하는지 확인
                        if (year == prevYear && month == prevMonthValue) {
                            trackCount += count.getCount();
                            log.debug("카운트 추가: {}", count.getCount());
                        }
                    }
                }
            }

            log.info("트랙 ID: {}, 트랙 스트리밍 횟수: {}", trackId, trackCount);
            totalCount += trackCount;
        }

        log.info("아티스트 ID {}, 전달({}) 총 스트리밍 횟수: {}",
                memberId, previousMonth, totalCount);

        return totalCount;
    }
}