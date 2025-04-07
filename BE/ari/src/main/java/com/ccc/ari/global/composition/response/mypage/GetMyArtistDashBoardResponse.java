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
    private Integer thisMonthStreamingCount;
    private Integer streamingDiff;
    private Integer thisMonthNewSubscriberCount;
    private Integer newSubscriberDiff;
    private BigDecimal thisMonthSettlement;
    private BigDecimal settlementDiff;
    private Integer todayStreamingCount;
    private Integer todayNewSubscribeCount;

    private List<MyArtistAlbum> albums;
    private List<MonthlySubscriberCount> monthlySubscriberCounts;
    private List<MonthlySettlement> monthlySettlement;
    private List<DailySubscriberCount> dailySubscriberCounts;


    @Builder
    public GetMyArtistDashBoardResponse(String walletAddress,Integer subscriberCount,Integer totalStreamingCount
            ,Integer thisMonthStreamingCount,Integer streamingDiff,Integer thisMonthNewSubscriberCount
    ,Integer newSubscriberDiff,BigDecimal thisMonthSettlement,BigDecimal settlementDiff, Integer todayStreamingCount,
                                        Integer todayNewSubscribeCount,List<MyArtistAlbum> albums,
                                        List<MonthlySubscriberCount> monthlySubscriberCounts,
                                        List<MonthlySettlement> monthlySettlement
                                        ,List<DailySubscriberCount> dailySubscriberCounts) {

        this.walletAddress = walletAddress;
        this.subscriberCount = subscriberCount;
        this.totalStreamingCount = totalStreamingCount;
        this.thisMonthStreamingCount = thisMonthStreamingCount;
        this.streamingDiff = streamingDiff;
        this.thisMonthNewSubscriberCount = thisMonthNewSubscriberCount;
        this.newSubscriberDiff = newSubscriberDiff;
        this.thisMonthSettlement = thisMonthSettlement;
        this.settlementDiff = settlementDiff;
        this.todayStreamingCount = todayStreamingCount;
        this.todayNewSubscribeCount = todayNewSubscribeCount;
        this.albums = albums;
        this.monthlySubscriberCounts = monthlySubscriberCounts;
        this.monthlySettlement = monthlySettlement;
        this.dailySubscriberCounts = dailySubscriberCounts;
    }

    @Getter
    @NoArgsConstructor
    public static class MyArtistAlbum{
        private String albumTitle;
        private String coverImageUrl;
        private Integer trackCount;

        @Builder
        public MyArtistAlbum(String albumTitle,String coverImageUrl,Integer trackCount){
            this.albumTitle = albumTitle;
            this.coverImageUrl = coverImageUrl;
            this.trackCount = trackCount;
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
    public static class MonthlySettlement{
        private String month;
        private Integer settlementCount;

        @Builder
        public MonthlySettlement(String month,Integer settlementCount){
            this.month = month;
            this.settlementCount = settlementCount;
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
