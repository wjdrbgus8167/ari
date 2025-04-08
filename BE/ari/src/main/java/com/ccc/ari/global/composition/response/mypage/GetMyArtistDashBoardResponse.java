package com.ccc.ari.global.composition.response.mypage;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Getter
@NoArgsConstructor
public class GetMyArtistDashBoardResponse {

    private String walletAddress;
    private Integer subscriberCount;
    private Integer totalStreamingCount;
    private Integer streamingDiff;
    private Integer thisMonthNewSubscriberCount;
    private Integer newSubscriberDiff;
    private Double settlementDiff;
    private Double todaySettlement;
    private Integer todayStreamingCount;
    private Integer todayNewSubscribeCount;

    private List<MyArtistAlbum> albums;
    private List<MonthlySubscriberCount> monthlySubscriberCounts;
    private List<DailySettlement> dailySettlement;
    private List<DailySubscriberCount> dailySubscriberCounts;


    @Builder
    public GetMyArtistDashBoardResponse(String walletAddress,Integer subscriberCount,Integer totalStreamingCount
            ,Integer streamingDiff,Integer thisMonthNewSubscriberCount
    ,Integer newSubscriberDiff,Double settlementDiff, Integer todayStreamingCount,
                                        Integer todayNewSubscribeCount,List<MyArtistAlbum> albums,
                                        List<MonthlySubscriberCount> monthlySubscriberCounts,
                                        List<DailySettlement> dailySettlement
                                        ,List<DailySubscriberCount> dailySubscriberCounts,Double todaySettlement) {

        this.walletAddress = walletAddress;
        this.subscriberCount = subscriberCount;
        this.totalStreamingCount = totalStreamingCount;
        this.streamingDiff = streamingDiff;
        this.thisMonthNewSubscriberCount = thisMonthNewSubscriberCount;
        this.newSubscriberDiff = newSubscriberDiff;
        this.settlementDiff = settlementDiff;
        this.todayStreamingCount = todayStreamingCount;
        this.todayNewSubscribeCount = todayNewSubscribeCount;
        this.albums = albums;
        this.monthlySubscriberCounts = monthlySubscriberCounts;
        this.dailySettlement = dailySettlement;
        this.dailySubscriberCounts = dailySubscriberCounts;
        this.todaySettlement = todaySettlement;
    }

    @Getter
    @NoArgsConstructor
    public static class MyArtistAlbum{
        private String albumTitle;
        private String coverImageUrl;
        private Integer totalStreaming;

        @Builder
        public MyArtistAlbum(String albumTitle,String coverImageUrl,Integer totalStreaming){
            this.albumTitle = albumTitle;
            this.coverImageUrl = coverImageUrl;
            this.totalStreaming = totalStreaming;
        }
    }

    @Getter
    @NoArgsConstructor
    public static class MonthlySubscriberCount{
        private String month;
        private Integer subscriberCount;

        @Builder
        public MonthlySubscriberCount(String month,Integer subscriberCount){
            this.month = month;
            this.subscriberCount = subscriberCount;
        }
    }

    @Getter
    @NoArgsConstructor
    public static class DailySettlement{
        private String date;
        private Double settlement;

        @Builder
        public DailySettlement(String date,Double settlement){
            this.date = date;
            this.settlement = settlement;
        }
    }

    @Getter
    @NoArgsConstructor
    public static class DailySubscriberCount{
        private String date;
        private Integer subscriberCount;

        @Builder
        public DailySubscriberCount(String date,Integer subscriberCount){
            this.date = date;
            this.subscriberCount = subscriberCount;
        }
    }
}
