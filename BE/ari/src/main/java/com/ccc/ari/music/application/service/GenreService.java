package com.ccc.ari.music.application.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.GenreEntity;
import com.ccc.ari.music.infrastructure.repository.genre.JpaGenreRepository;
import com.ccc.ari.music.mapper.GenreMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GenreService {

    private final JpaGenreRepository jpaGenreRepository;

    public GenreDto getGenre(String genreName) {
        GenreEntity genreEntity = jpaGenreRepository.findByGenreName(genreName)
                .orElseThrow(() -> new ApiException(ErrorCode.GENRE_NOT_FOUND));


        return GenreMapper.toDto(genreEntity);
    }

    public String getGenreName(Integer genreId) {
        GenreEntity genreEntity = jpaGenreRepository.findByGenreId(genreId)
                .orElseThrow(() -> new ApiException(ErrorCode.GENRE_NOT_FOUND));

        GenreDto genreDto = GenreMapper.toDto(genreEntity);
        return genreDto.getGenreName();
    }
}
