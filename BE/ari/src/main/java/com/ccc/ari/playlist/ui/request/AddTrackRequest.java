package com.ccc.ari.playlist.ui.request;

import com.ccc.ari.playlist.application.command.AddTrackCommand;
import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@NoArgsConstructor
public class AddTrackRequest {

    List<TrackRequest> tracks;

    @Getter
    @NoArgsConstructor
    public static class TrackRequest {
        Integer trackId;
    }

    public AddTrackCommand toCommand(Integer playlistId) {
        return AddTrackCommand.builder()
                .playlistId(playlistId)
                .trackIds(
                        this.tracks.stream()
                                .map(TrackRequest::getTrackId)
                                .toList()
                )
                .build();
    }
}
