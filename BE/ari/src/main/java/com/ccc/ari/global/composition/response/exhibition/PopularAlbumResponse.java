package com.ccc.ari.global.composition.response.exhibition;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class PopularAlbumResponse {

    private List<PopularAlbumItem> albums;

    @Getter
    @Builder
    public static class PopularAlbumItem {
        private Integer albumId;
        private String albumTitle;
        private String artist;
        private String coverImageUrl;
        private String genreName;
        private Integer trackCount;
        private List<TrackItem> tracks;
    }

    @Getter
    @Builder
    public static class TrackItem {
        private Integer trackId;
        private String trackTitle;
    }
}
