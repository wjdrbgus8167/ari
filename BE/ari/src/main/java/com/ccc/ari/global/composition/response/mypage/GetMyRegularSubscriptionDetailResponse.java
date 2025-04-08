package com.ccc.ari.global.composition.response.mypage;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Getter
@NoArgsConstructor
public class GetMyRegularSubscriptionDetailResponse {

    private BigDecimal price;
    private List<Settlement> settlements;

    @Builder
    public GetMyRegularSubscriptionDetailResponse(BigDecimal price,List<Settlement> settlements) {
        this.price = price;
        this.settlements = new ArrayList<>();
    }

    @Getter
    @NoArgsConstructor
    public static class Settlement{
        private String artistNickName;
        private String profileImageUrl;
        private Integer streaming;
        private Double amount;

        @Builder
        public Settlement(String artistNickName, String profileImageUrl
                , Integer streaming,Double amount) {

            this.artistNickName = artistNickName;
            this.profileImageUrl = profileImageUrl;
            this.streaming = streaming;
            this.amount = amount;
        }
    }
}
