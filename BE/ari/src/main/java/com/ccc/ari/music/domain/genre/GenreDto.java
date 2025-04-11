package com.ccc.ari.music.domain.genre;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class GenreDto {
    private Integer genreId;
    private String genreName;
}
