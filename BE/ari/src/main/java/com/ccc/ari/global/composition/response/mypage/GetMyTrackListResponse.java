package com.ccc.ari.global.composition.response.mypage;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetMyTrackListResponse {
    private String trackTitle;
    private String coverImageUrl;
    private String monthlyStreamingCount;
    private String totalStreamingCount;

    @Builder
    public GetMyTrackListResponse(String trackTitle,String coverImageUrl,String monthlyStreamingCount,String totalStreamingCount) {
        this.trackTitle = trackTitle;
        this.coverImageUrl = coverImageUrl;
        this.monthlyStreamingCount = monthlyStreamingCount;
        this.totalStreamingCount = totalStreamingCount;

    }

}
