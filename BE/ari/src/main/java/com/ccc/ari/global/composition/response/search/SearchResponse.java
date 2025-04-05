package com.ccc.ari.global.composition.response.search;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
public class SearchResponse {

    private final List<ArtistItem> artists;
    private final List<TrackItem> tracks;

    @Builder
    public SearchResponse(List<ArtistItem> artists, List<TrackItem> tracks) {
        this.artists = artists;
        this.tracks = tracks;
    }

    @Getter
    @Builder
    public static class ArtistItem {
        private Integer memberId;
        private String nickname;
        private String profileImageUrl;
    }

    @Getter
    @Builder
    public static class TrackItem {
        private Integer trackId;
        private String trackTitle;
        private String artist;
        private String coverImageUrl;
    }
}
