package com.ccc.ari.music.mapper;

import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.GenreEntity;

public class GenreMapper {

    public static GenreDto toDto(GenreEntity entity) {
        return GenreDto.builder()
                .genreId(entity.getGenreId())
                .genreName(entity.getGenreName())
                .build();
    }

    public static GenreEntity toEntity(GenreDto dto) {
        return GenreEntity.builder()
                .genreId(dto.getGenreId())
                .genreName(dto.getGenreName())
                .build();
    }
}
