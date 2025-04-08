package com.ccc.ari.global.composition.response.community;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
public class LikeAlbumListResponse {

    private List<AlbumItem> albums;
    private Integer albumCount;

    @Builder
    public LikeAlbumListResponse(List<AlbumItem> albums, Integer albumCount) {
        this.albums = albums;
        this.albumCount = albumCount;
    }

    @Getter
    @Builder
    public static class AlbumItem {
        private Integer albumId;
        private String albumTitle;
        private String artist;
        private String coverImageUrl;
        private Integer trackCount;
    }
}
