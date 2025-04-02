package com.ccc.ari.playlist.ui.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class GetPlayListResponse {

    List<PlaylistResponse> playlists;

    @Getter
    @NoArgsConstructor
    public static class PlaylistResponse {
        Integer playlistId;
        String playlistTitle;
        boolean publicYn;
        int trackCount; // 곡 개수

        @Builder
        public PlaylistResponse(Integer playlistId, String playlistTitle,boolean publicYn, int trackCount) {
            this.playlistId = playlistId;
            this.playlistTitle = playlistTitle;
            this.publicYn = publicYn;
            this.trackCount = trackCount;

        }
    }

   @Builder
    public GetPlayListResponse(List<PlaylistResponse> playlists) {
        this.playlists = playlists;
   }
}