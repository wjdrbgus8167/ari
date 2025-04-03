package com.ccc.ari.playlist.infrastructure;

import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface JpaPlaylistTrackRepository extends JpaRepository<PlaylistTrackEntity, Integer> {

    void deleteByPlaylist_PlaylistIdAndTrack_TrackId(Integer playlistId, Integer trackId);

}
