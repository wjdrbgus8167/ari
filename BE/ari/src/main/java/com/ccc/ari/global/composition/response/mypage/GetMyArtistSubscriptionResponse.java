package com.ccc.ari.global.composition.response.mypage;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class GetMyArtistSubscriptionResponse {

    private List<MyArtisSubscription> artists;

    @Builder
    public GetMyArtistSubscriptionResponse(List<MyArtisSubscription> artists) {
        this.artists = artists;
    }

    @Getter
    @NoArgsConstructor
    public static class MyArtisSubscription {
        private Integer artistId;
        private String artistNickName;

        @Builder
        public MyArtisSubscription(Integer artistId, String artistNickName) {
            this.artistId = artistId;
            this.artistNickName = artistNickName;
        }
    }
}
