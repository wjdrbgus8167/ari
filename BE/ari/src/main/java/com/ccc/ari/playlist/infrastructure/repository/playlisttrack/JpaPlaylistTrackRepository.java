package com.ccc.ari.playlist.infrastructure.repository.playlisttrack;

import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface JpaPlaylistTrackRepository extends JpaRepository<PlaylistTrackEntity, Integer> {

    void deleteByPlaylist_PlaylistIdAndTrack_TrackId(Integer playlistId, Integer trackId);
    List<PlaylistTrackEntity> findAllByPlaylist_PlaylistId(Integer playlistId);
}
