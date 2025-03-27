package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class DeleteTrackCommand {

    Integer playlistId;
    Integer trackId;

    @Builder
    public DeleteTrackCommand(Integer playlistId, Integer trackId) {
        this.playlistId = playlistId;
        this.trackId = trackId;
    }
}