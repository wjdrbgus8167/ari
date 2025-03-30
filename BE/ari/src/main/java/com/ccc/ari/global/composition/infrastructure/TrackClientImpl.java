package com.ccc.ari.global.composition.infrastructure;

import com.ccc.ari.music.application.service.TrackService;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.music.domain.track.TrackDto;
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
}
