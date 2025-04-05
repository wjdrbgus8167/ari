package com.ccc.ari.global.composition.response.mypage;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/*
    현재 내가 구독한 월간 구독(정기 구독) + 아티스트 구독 목록 Response
    MonthlySubscriptionResponse -> 정기 구독
    ArtistSubscriptionResponse -> 아티스트 구독
 */
@Getter
@NoArgsConstructor
public class GetMySubscriptionListResponse {

    private List<MonthlySubscriptionResponse> monthly ;
    private List<ArtistSubscriptionResponse> artist;

    @Builder
    public GetMySubscriptionListResponse(List<MonthlySubscriptionResponse> monthly
            , List<ArtistSubscriptionResponse> artist) {
        this.monthly = monthly;
        this.artist = artist;
    }

    @Getter
    @NoArgsConstructor
    public static class MonthlySubscriptionResponse {

        private BigDecimal price;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime subscribeAt;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime expiredAt;

        @Builder
        public MonthlySubscriptionResponse(BigDecimal price, LocalDateTime subscribeAt, LocalDateTime expiredAt) {
            this.price = price;
            this.subscribeAt = subscribeAt;
            this.expiredAt = expiredAt;
        }


    }

    @Getter
    @NoArgsConstructor
    public static class ArtistSubscriptionResponse {

        private String artistName;
        private BigDecimal price;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime subscribeAt;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime expiredAt;

        @Builder
        public ArtistSubscriptionResponse(String artistName,BigDecimal price,
                                          LocalDateTime subscribeAt, LocalDateTime expiredAt) {
            this.artistName = artistName;
            this.price = price;
            this.subscribeAt = subscribeAt;
            this.expiredAt = expiredAt;

        }
    }
}
