package com.ccc.ari.music.domain.track.client;

import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.TrackEntity;

import java.util.List;

public interface TrackClient {
    List<TrackDto> getTracksByAlbumId(Integer albumId);
    TrackDto getTrackById(Integer trackId);
    List<TrackEntity> saveTracks(List<TrackEntity> trackEntities);
    TrackDto getTrackByAlbumIdAndTrackId(Integer albumId, Integer trackId);
}
