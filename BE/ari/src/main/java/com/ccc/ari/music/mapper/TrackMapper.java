package com.ccc.ari.music.mapper;

import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.TrackEntity;

public class TrackMapper {

    public static TrackDto toDto(TrackEntity entity) {
        return TrackDto.builder()
                .trackId(entity.getTrackId())
                .title(entity.getTrackTitle())
                .composer(entity.getComposer())
                .lyricist(entity.getLyricist())
                .lyrics(entity.getLyrics())
                .trackNumber(entity.getTrackNumber())
                .trackFileUrl(entity.getTrackFileUrl())
                .trackLikeCount(entity.getTrackLikeCount())
                .gereName(entity.getAlbum().getGenre().getGenreName())
                .build();
    }
}
