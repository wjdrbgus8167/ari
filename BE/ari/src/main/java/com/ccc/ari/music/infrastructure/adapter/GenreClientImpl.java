package com.ccc.ari.music.infrastructure.adapter;

import com.ccc.ari.music.application.service.GenreService;
import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.client.GenreClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class GenreClientImpl implements GenreClient {

    private final GenreService genreService;

    @Override
    public GenreDto getGenre(String genreName) {

        return genreService.getGenre(genreName);
    }

    @Override
    public String getGenreName(Integer genreId) {
        return genreService.getGenreName(genreId);
    }
}
