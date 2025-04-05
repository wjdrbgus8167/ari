package com.ccc.ari.global.composition.response.exhibition;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class PopularPlaylistResponse {
    private List<PopularPlaylistResponse.PopularPlaylistItem> playlists;

    @Getter
    @Builder
    public static class PopularPlaylistItem {
        private Integer playlistId;
        private String memberName;
        private String playlistTitle;
        private String coverImageUrl;
        private Integer trackCount;
        private List<TrackItem> tracks;
    }

    @Getter
    @Builder
    public static class TrackItem {
        private Integer trackId;
        private Integer albumId;
        private String trackTitle;
        private String trackCoverImageUrl;
        private String artistName;
    }
}
