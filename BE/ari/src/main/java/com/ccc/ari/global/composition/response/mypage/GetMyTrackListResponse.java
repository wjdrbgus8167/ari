package com.ccc.ari.global.composition.response.mypage;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class GetMyTrackListResponse {

    private List<MyTrack> tracks;

    @Builder
    public GetMyTrackListResponse(List<MyTrack> tracks) {
        this.tracks = tracks;
    }

    @Getter
    @NoArgsConstructor
    public static class MyTrack{

        private String trackTitle;
        private String coverImageUrl;
        private Integer monthlyStreamingCount;
        private Integer totalStreamingCount;

        @Builder
        public MyTrack(String trackTitle,String coverImageUrl,Integer monthlyStreamingCount,Integer totalStreamingCount) {
            this.trackTitle = trackTitle;
            this.coverImageUrl = coverImageUrl;
            this.monthlyStreamingCount = monthlyStreamingCount;
            this.totalStreamingCount = totalStreamingCount;

        }
    }


}
