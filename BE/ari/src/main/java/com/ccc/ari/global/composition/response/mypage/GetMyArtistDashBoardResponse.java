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
    private List<HourlySettlement> hourlySettlement;
    private List<HourlySubscriberCount> hourlySubscriberCounts;


    @Builder
    public GetMyArtistDashBoardResponse(String walletAddress,Integer subscriberCount,Integer totalStreamingCount
            ,Integer streamingDiff,Integer thisMonthNewSubscriberCount
    ,Integer newSubscriberDiff,Double settlementDiff, Integer todayStreamingCount,
                                        Integer todayNewSubscribeCount,List<MyArtistAlbum> albums,
                                        List<MonthlySubscriberCount> monthlySubscriberCounts,
                                        List<HourlySettlement> hourlySettlement
                                        ,List<HourlySubscriberCount> hourlySubscriberCounts,Double todaySettlement) {

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
        this.hourlySettlement = hourlySettlement;
        this.hourlySubscriberCounts = hourlySubscriberCounts;
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
    public static class HourlySettlement{
        private String hour;
        private Double settlement;

        @Builder
        public HourlySettlement(String hour,Double settlement){
            this.hour = hour;
            this.settlement = settlement;
        }
    }

    @Getter
    @NoArgsConstructor
    public static class HourlySubscriberCount{
        private String hour;
        private Integer subscriberCount;

        @Builder
        public HourlySubscriberCount(String hour,Integer subscriberCount){
            this.hour = hour;
            this.subscriberCount = subscriberCount;
        }
    }
}
