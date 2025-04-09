package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.aggregation.application.service.response.GetArtistStreamingResponse;
import com.ccc.ari.aggregation.ui.client.StreamingCountClient;
import com.ccc.ari.global.composition.response.mypage.GetMyArtistDashBoardResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.settlement.application.response.GetArtistDailySettlementResponse;
import com.ccc.ari.settlement.ui.client.SettlementClient;
import com.ccc.ari.settlement.ui.client.WalletClient;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.client.SubscriptionClient;
import com.ccc.ari.subscription.domain.client.SubscriptionPlanClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
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
    private final WalletClient walletClient;
    private final SettlementClient settlementClient;

    // 아티스트 대시보드 조회
    public GetMyArtistDashBoardResponse getMyArtistDashBoard(Integer memberId) {

        /**
          * 현재 아티스트의 플랜을 조회 , 플랜이 존재한다면 구독한 사용자가 있다는 의미
         * 대시보드에 들어오기 전에 지갑 검사로 아티스트임을 판별
         */
        SubscriptionPlan subscriptionPlan = subscriptionPlanClient.getSubscriptionPlanByArtistId(memberId)
                .orElse(null);
        // 지갑 주소
        String walletAddress = walletClient.getWalletByArtistId(memberId).getAddress();

        if(walletAddress == null){
            throw new ApiException(ErrorCode.WALLET_NOT_REGTISTER);
        }

        if (subscriptionPlan==null) {
            return GetMyArtistDashBoardResponse.builder()
                    .subscriberCount(0)
                    .totalStreamingCount(0)
                    .streamingDiff(0)
                    .thisMonthNewSubscriberCount(0)
                    .albums(new ArrayList<>())
                    .dailySettlement(new ArrayList<>())
                    .walletAddress(walletAddress) // 혹은 null
                    .newSubscriberDiff(0)
                    .settlementDiff(0.0)
                    .todaySettlement(0.0)
                    .dailySubscriberCounts(new ArrayList<>())
                    .monthlySubscriberCounts(new ArrayList<>())
                    .todayStreamingCount(0)
                    .todayNewSubscribeCount(0)
                    .build();
        }
        // 아티스트 앨범 리스트 조회
        List<AlbumEntity> albumDtoList = albumClient.getAllAlbums(memberId)
                .orElse(null);

        log.info("구독Plan 아티스트ID:{}", subscriptionPlan.getArtistId());

        // 아티스트의 구독 Plan ID 가져오기
        Integer subscriptionPlanId = subscriptionPlan.getSubscriptionPlanId().getValue();
        log.info("구독Plan ID:{}", subscriptionPlanId);

        // 아티스트 스트리밍 데이터 가져오기
        GetArtistStreamingResponse getArtistStreamingResponse = streamingCountClient.getArtistAlbumStreamings(memberId);

        // 현재 구독자 수 조회 - 활성화 되어 있는 구독자만 가져옴
        Integer subscriberCount = subscriptionClient
                .getSubscriptionBySubscriptionPlanId(subscriptionPlanId).size();
        log.info("현재 구독자 수:{}", subscriberCount);

        // 이번 달 구독 시작 시간/끝 시간 계산
        LocalDateTime startOfMonth = YearMonth.now().atDay(1).atStartOfDay();
        LocalDateTime endOfMonth = YearMonth.now().atEndOfMonth().atTime(23, 59, 59, 999_999_999);
        log.info("이번 달 구독 시작 시간:{}",startOfMonth);
        log.info("이번 달 구독 종료 시간:{}",endOfMonth);

        // 이번 달 신규 구독자 수
        Integer thisMonthNewSubscriberCount = subscriptionClient
                .getRegularSubscription(subscriptionPlanId, startOfMonth, endOfMonth).size();


        // 오늘 하루 구독자 날짜
        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = LocalDate.now().atTime(23, 59, 59, 999_999_999);

        // 오늘 하루 신규 구독자 수
        Integer todayNewSubscribeCount =
                subscriptionClient.getRegularSubscription(subscriptionPlanId,startOfToday,endOfToday).size();

        log.info("이번달 신규 구독자 수 :{}", thisMonthNewSubscriberCount);
        log.info("오늘 하루 신규 구독자:{}", todayNewSubscribeCount);

        // 스트리밍 횟수 차, 이번 달 - 전달
        int streamingDiff = getArtistStreamingResponse.getStreamingDiff();

        // 아티스트 앨범 목록 조회
        List<GetMyArtistDashBoardResponse.MyArtistAlbum> albums =
                getArtistStreamingResponse.getAlbumStreamings().stream().map(albumEntity -> {

                    AlbumDto album = albumClient.getAlbumById(albumEntity.getAlbumId());

                    return GetMyArtistDashBoardResponse.MyArtistAlbum.builder()
                            .albumTitle(album.getTitle())
                            .coverImageUrl(album.getCoverImageUrl())
                            .totalStreaming(albumEntity.getTotalStreaming())
                            .build();
                }).toList();

        // 아티스트 전체 스트리밍 횟수
        Integer totalStreamingCount = getArtistStreamingResponse.getTotalStreamingCount();
        // 오늘 스트리밍 횟수
        Integer todayStreamingCount = getArtistStreamingResponse.getTodayStreamingCount();

        // 이전 달의 마지막 날 계산
        LocalDateTime endOfPreviousMonth = YearMonth.now().minusMonths(1)
                .atEndOfMonth().atTime(23, 59, 59, 999_999_999);
        // 3월달부터 플랫폼을 운행했다는 가정하에 3월부터 이전 달까지 구독자의 수 가져오기 위한 시간
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


        //월 정산
        GetArtistDailySettlementResponse getArtistDailySettlementResponse
                = settlementClient.getArtistDailySettlement(memberId);

        // 일일 정산 내역
        List<GetMyArtistDashBoardResponse.DailySettlement> dailySettlementList =
                getArtistDailySettlementResponse.getDailySettlements().stream()
                        .map(daily -> GetMyArtistDashBoardResponse.DailySettlement.builder()
                                .date(daily.getDate())
                                .settlement(daily.getSettlement())
                                .build())
                        .toList();


        return GetMyArtistDashBoardResponse.builder()
                .subscriberCount(subscriberCount)
                .totalStreamingCount(totalStreamingCount)
                .streamingDiff(streamingDiff)
                .thisMonthNewSubscriberCount(thisMonthNewSubscriberCount)
                .albums(albums)
                .dailySettlement(dailySettlementList)
                .walletAddress(walletAddress)
                .newSubscriberDiff(newSubscriberDiff)
                .settlementDiff(getArtistDailySettlementResponse.getSettlementDiff())
                .todaySettlement(getArtistDailySettlementResponse.getTodaySettlement())
                .dailySubscriberCounts(dailySubscriberCounts)
                .monthlySubscriberCounts(monthlySubscriberCounts)
                .todayStreamingCount(todayStreamingCount)
                .todayNewSubscribeCount(todayNewSubscribeCount)
                .build();
    }

}