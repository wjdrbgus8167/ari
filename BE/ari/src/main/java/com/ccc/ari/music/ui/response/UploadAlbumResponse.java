package com.ccc.ari.music.ui.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class UploadAlbumResponse {
    private Integer albumId;
    private String albumTitle;
    private String coverImageUrl;
    private String description;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime releasedAt;
    private String genre;
    private Integer memberId;
    private String nickname;
    private Integer trackCount;
    private List<TrackResponse> tracks;

    @Builder
    public UploadAlbumResponse(Integer albumId, String albumTitle, String coverImageUrl,
                               String description, LocalDateTime releasedAt, String genre, Integer memberId,
                               String nickname,  Integer trackCount,List<TrackResponse> tracks) {
        this.albumId = albumId;
        this.albumTitle = albumTitle;
        this.coverImageUrl = coverImageUrl;
        this.description = description;
        this.releasedAt = releasedAt;
        this.genre = genre;
        this.memberId = memberId;
        this.nickname = nickname;
        this.trackCount = trackCount;
        this.tracks = tracks;
    }

    @Getter
    @NoArgsConstructor
    public static class TrackResponse {
        private Integer trackId;
        private String trackTitle;
        private Integer trackNumber;
        private String composer;
        private String lyricist;
        private String lyrics;
        private String trackFileUrl;

        @Builder
        public TrackResponse(Integer trackId, String trackTitle, Integer trackNumber,
                             String composer, String lyricist, String lyrics, String trackFileUrl) {
            this.trackId = trackId;
            this.trackTitle = trackTitle;
            this.trackNumber = trackNumber;
            this.composer = composer;
            this.lyricist = lyricist;
            this.lyrics = lyrics;
            this.trackFileUrl = trackFileUrl;
        }
    }

}

