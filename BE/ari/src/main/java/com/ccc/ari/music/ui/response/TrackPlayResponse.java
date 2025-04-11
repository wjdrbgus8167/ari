package com.ccc.ari.music.ui.response;

import lombok.Builder;
import lombok.Getter;

@Getter
public class TrackPlayResponse {
    String trackFileUrl;
    String coverImageUrl;
    String title;
    String artist;
    String lyrics;

    @Builder
    public TrackPlayResponse(String tackFileUrl, String coverImageUrl,String title, String artist, String lyrics) {
        this.trackFileUrl = tackFileUrl;
        this.coverImageUrl = coverImageUrl;
        this.title = title;
        this.artist = artist;
        this.lyrics = lyrics;
    }

}
