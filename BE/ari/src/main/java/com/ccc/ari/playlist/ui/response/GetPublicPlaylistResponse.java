package com.ccc.ari.playlist.ui.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class GetPublicPlaylistResponse {
    private List<PlaylistResponse> playlists;

    @Getter
    @NoArgsConstructor
    public static class PlaylistResponse {
        private Integer playlistId;
        private String playlistTitle;
        private boolean publicYn;
        private Integer shareCount;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
        private LocalDateTime createdAt;
        private String nickname;
        private int trackCount; // 곡 개수

        @Builder
        public PlaylistResponse(Integer playlistId, String playlistTitle,boolean publicYn, int trackCount
        , LocalDateTime createdAt, String nickname, int shareCount) {
            this.playlistId = playlistId;
            this.playlistTitle = playlistTitle;
            this.publicYn = publicYn;
            this.trackCount = trackCount;
            this.createdAt = createdAt;
            this.nickname = nickname;
            this.shareCount = shareCount;
        }
    }

    @Builder
    public GetPublicPlaylistResponse(List<PlaylistResponse> playlists) {
        this.playlists = playlists;
    }
}
