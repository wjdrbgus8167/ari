package com.ccc.ari.music.infrastructure.track;

import com.ccc.ari.music.domain.track.TrackEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface JpaTrackRepository extends JpaRepository<TrackEntity,Integer> {
    Optional<TrackEntity> findByAlbum_AlbumIdAndTrackId(Integer albumId, Integer trackId);

}
