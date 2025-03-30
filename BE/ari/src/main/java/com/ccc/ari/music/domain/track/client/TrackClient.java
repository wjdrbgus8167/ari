package com.ccc.ari.music.domain.track.client;

import com.ccc.ari.music.domain.track.TrackDto;

import java.util.List;

public interface TrackClient {
    List<TrackDto> getTracksByAlbumId(Integer albumId);
}
