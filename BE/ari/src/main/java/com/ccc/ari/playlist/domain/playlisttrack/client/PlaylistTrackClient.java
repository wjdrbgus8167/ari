package com.ccc.ari.playlist.domain.playlisttrack.client;

import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;

import java.util.List;

public interface PlaylistTrackClient {

    Integer getTrackCount(Integer playlistId);
    List<PlaylistTrackEntity> getPlaylistTracks(Integer playlistId);
}
