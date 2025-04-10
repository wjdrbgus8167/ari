package com.ccc.ari.global.composition.response.community;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
public class LikeTrackListResponse {

    private List<TrackItem> tracks;
    private Integer trackCount;

    @Builder
    public LikeTrackListResponse(List<TrackItem> tracks, Integer trackCount) {
        this.tracks = tracks;
        this.trackCount = trackCount;
    }

    @Getter
    @Builder
    public static class TrackItem {
        private Integer albumId;
        private Integer trackId;
        private String trackTitle;
        private String artist;
        private String coverImageUrl;
    }
}
