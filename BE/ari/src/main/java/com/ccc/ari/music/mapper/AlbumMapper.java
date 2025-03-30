package com.ccc.ari.music.mapper;

import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;

public class AlbumMapper {

    public static AlbumDto toDto(AlbumEntity entity) {
        return AlbumDto.builder()
                .albumId(entity.getAlbumId())
                .title(entity.getAlbumTitle())
                .artist(entity.getMember().getNickname())
                .genreName(entity.getGenre().getGenreName())
                .coverImageUrl(entity.getCoverImageUrl())
                .releasedAt(entity.getReleasedAt())
                .description(entity.getDescription())
                .albumLikeCount(entity.getAlbumLikeCount())
                .build();
    }
}
