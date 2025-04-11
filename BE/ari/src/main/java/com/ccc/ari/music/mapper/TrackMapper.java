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
                // TODO : genre 구현되고 이 부분 수정해야됨. 그리고 AlbumEntity 수정하면서 albumId 부분 수정해야됨.
                .albumId(entity.getAlbum().getAlbumId())
                .gereName(entity.getAlbum().getGenre().getGenreName())
                .build();
    }
}
