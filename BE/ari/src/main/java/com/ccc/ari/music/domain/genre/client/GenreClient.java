package com.ccc.ari.music.domain.genre.client;

import com.ccc.ari.music.domain.genre.GenreDto;

public interface GenreClient {

    GenreDto getGenre(String genreName);

    String getGenreName(Integer genreId);
}
