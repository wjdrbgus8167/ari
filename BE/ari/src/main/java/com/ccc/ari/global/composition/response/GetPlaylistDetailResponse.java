package com.ccc.ari.global.composition.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;


@Getter
@NoArgsConstructor
public class GetPlaylistDetailResponse {
    List<TrackDetail> tracks;

    @Getter
    @NoArgsConstructor
    public static class TrackDetail {
        int trackOrder;
        Integer trackId;
        String artist;
        Integer artistId;
        String composer;
        String lyricist;
        String lyrics;
        String trackFileUrl;
        Integer trackLikeCount;
        Integer trackNumber;
        String trackTitle;
        String coverImageUrl;
        Integer albumId;

        @Builder
        public TrackDetail(int trackOrder,Integer trackId,String composer, String lyricist, String lyrics,
                           String trackFileUrl, Integer trackLikeCount, Integer trackNumber, String trackTitle
                           ,String coverImageUrl,String artist,Integer albumId,Integer artistId) {
            this.trackOrder = trackOrder;
            this.trackId = trackId;
            this.composer = composer;
            this.lyricist = lyricist;
            this.lyrics = lyrics;
            this.trackFileUrl = trackFileUrl;
            this.trackLikeCount = trackLikeCount;
            this.trackNumber = trackNumber;
            this.trackTitle = trackTitle;
            this.albumId = albumId;
            this.coverImageUrl = coverImageUrl;
            this.artist = artist;
            this.artistId = artistId;
        }
    }

    @Builder
    public GetPlaylistDetailResponse(List<TrackDetail> tracks) {
        this.tracks = tracks;
    }


}
