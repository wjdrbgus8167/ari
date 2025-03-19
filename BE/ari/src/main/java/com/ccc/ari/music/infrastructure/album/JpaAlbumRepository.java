package com.ccc.ari.music.infrastructure.album;

import com.ccc.ari.music.domain.album.AlbumEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface JpaAlbumRepository extends JpaRepository<AlbumEntity,Integer> {
    Optional<AlbumEntity> findByAlbumId(Integer albumId);
}
