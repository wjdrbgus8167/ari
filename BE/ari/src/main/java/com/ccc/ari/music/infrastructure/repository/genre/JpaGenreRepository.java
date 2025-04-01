package com.ccc.ari.music.infrastructure.repository.genre;

import com.ccc.ari.music.domain.genre.GenreEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface JpaGenreRepository extends JpaRepository<GenreEntity,Integer> {

    Optional<GenreEntity> findByGenreName(String genreName);
    Optional<GenreEntity> findByGenreId(Integer genreId);
}
