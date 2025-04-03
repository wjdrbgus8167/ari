package com.ccc.ari.playlist.infrastructure.adapter;

import com.ccc.ari.playlist.application.service.PlaylistTrackService;
import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import com.ccc.ari.playlist.domain.playlisttrack.client.PlaylistTrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class PlaylistTrackClientImpl implements PlaylistTrackClient {

    private final PlaylistTrackService playlistTrackService;

    @Override
    public Integer getTrackCount(Integer playlistId) {
        return playlistTrackService.getTrackCount(playlistId);

    }

    @Override
    public List<PlaylistTrackEntity> getPlaylistTracks(Integer playlistId) {
        return playlistTrackService.getPlaylistTracks(playlistId);
    }
}
