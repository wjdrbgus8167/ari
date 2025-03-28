package com.ccc.ari.music.infrastructure.genre;

import com.ccc.ari.music.domain.genre.GenreEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface JpaGenreRepository extends JpaRepository<GenreEntity,Integer> {
}
