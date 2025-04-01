package com.ccc.ari.music.infrastructure.adapter;

import com.ccc.ari.music.application.service.TrackService;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class TrackClientImpl implements TrackClient {

    private final TrackService trackService;
    @Override
    public List<TrackDto> getTracksByAlbumId(Integer albumId) {
        return trackService.getTracksByAlbumId(albumId);
    }

    @Override
    public TrackDto getTrackById(Integer trackId) {
        return trackService.getTrackById(trackId);
    }

    @Override
    public List<TrackEntity> saveTracks(List<TrackEntity> trackEntities) {

        return trackService.saveTracks(trackEntities);
    }

    @Override
    public TrackDto getTrackByAlbumIdAndTrackId(Integer albumId, Integer trackId) {
        return trackService.getTrackByAlbumIdAndTrackId(albumId,trackId);
    }
}
