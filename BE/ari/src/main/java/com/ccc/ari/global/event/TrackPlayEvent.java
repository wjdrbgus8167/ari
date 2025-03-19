package com.ccc.ari.global.event;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
public class TrackPlayEvent {

    private Integer trackId;
    private String trackTitle;
    private Integer albumId;
    private String albumTitle;
    private Integer genreId;
    private String genreName;
    private String artist;
    private Instant timestamp;

    @Builder
    public TrackPlayEvent(Integer trackId,String trackTitle, Integer albumId, String albumTitle
            , Integer genreId, String genreName, String artist
            , Instant timestamp) {

        this.trackId = trackId;
        this.trackTitle = trackTitle;
        this.albumId = albumId;
        this.albumTitle = albumTitle;
        this.genreId = genreId;
        this.genreName = genreName;
        this.artist = artist;
        this.timestamp = timestamp;
    }
}
