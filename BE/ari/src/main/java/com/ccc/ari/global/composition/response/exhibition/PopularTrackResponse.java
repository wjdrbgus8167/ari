package com.ccc.ari.global.composition.response.exhibition;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class PopularTrackResponse {

    private List<PopularTrackItem> tracks;

    @Getter
    @Builder
    public static class PopularTrackItem {
        private Integer trackId;
        private String trackTitle;
        private String artist;
        private String coverImageUrl;
    }
}
