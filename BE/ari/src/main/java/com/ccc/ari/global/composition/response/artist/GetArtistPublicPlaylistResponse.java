package com.ccc.ari.global.composition.response.artist;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class GetArtistPublicPlaylistResponse {

    private String artist;
    private List<ArtistPublicPlaylistResponse> playlists;

    @Getter
    @NoArgsConstructor
    public static class ArtistPublicPlaylistResponse {
        Integer playlistId;
        String playlistTitle;
        boolean publicYn;
        int trackCount; // 곡 개수
        String artist;
        String coverImageUrl;

        @Builder
        public ArtistPublicPlaylistResponse(Integer playlistId, String playlistTitle,boolean publicYn, int trackCount,
                                String artist, String coverImageUrl) {
            this.playlistId = playlistId;
            this.playlistTitle = playlistTitle;
            this.publicYn = publicYn;
            this.trackCount = trackCount;
            this.artist = artist;
            this.coverImageUrl = coverImageUrl;
        }
    }

    @Builder
    public GetArtistPublicPlaylistResponse(String artist, List<ArtistPublicPlaylistResponse> playlists) {
        this.artist = artist;
        this.playlists = playlists;
    }
}