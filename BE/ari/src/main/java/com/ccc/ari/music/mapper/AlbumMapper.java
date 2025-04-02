package com.ccc.ari.music.mapper;

import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;

public class AlbumMapper {

    public static AlbumDto toDto(AlbumEntity entity) {
        return AlbumDto.builder()
                .albumId(entity.getAlbumId())
                .title(entity.getAlbumTitle())
                // TODO : 추후 수정 예정
                .memberId(entity.getMember().getMemberId())
                .artist(entity.getMember().getNickname())
                // TODO : 추후 수정 예정
                .genreName(entity.getGenre().getGenreName())
                .coverImageUrl(entity.getCoverImageUrl())
                .releasedAt(entity.getReleasedAt())
                .description(entity.getDescription())
                .albumLikeCount(entity.getAlbumLikeCount())
                .build();
    }

    public static AlbumEntity toEntity(AlbumDto dto) {
        return AlbumEntity.builder()
                .albumTitle(dto.getTitle())
                .description(dto.getDescription())
                .albumLikeCount(dto.getAlbumLikeCount())
                .releasedAt(dto.getReleasedAt())
                .coverImageUrl(dto.getCoverImageUrl())
                .build();
    }
}
