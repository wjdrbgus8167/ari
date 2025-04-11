package com.ccc.ari.global.composition.response.mypage;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class GetMyArtistSubscriptionDetailResponse {

    private String artistNickName;
    private String profileImageUrl;
    private Double totalSettlement;
    private Integer totalStreamingCount;
    private List<ArtistSubscriptionDetail> subscriptions;

    @Builder
    public GetMyArtistSubscriptionDetailResponse(String artistNickName, String profileImageUrl
            , Double totalSettlement, Integer totalStreamingCount,List<ArtistSubscriptionDetail> subscriptions) {
        this.artistNickName = artistNickName;
        this.profileImageUrl = profileImageUrl;
        this.totalSettlement = totalSettlement;
        this.totalStreamingCount = totalStreamingCount;
        this.subscriptions = subscriptions;

    }

    @Getter
    @NoArgsConstructor
    public static class ArtistSubscriptionDetail{
        private String planType;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime startedAt;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime endedAt;
        private Double settlement;


        @Builder
        public ArtistSubscriptionDetail(String planType, LocalDateTime startedAt
                , LocalDateTime endedAt, Double settlement) {
            this.planType = planType;
            this.startedAt = startedAt;
            this.endedAt = endedAt;
            this.settlement = settlement;
        }
    }
}
