package com.ccc.ari.music.application.command;

import lombok.Builder;
import lombok.Getter;

@Getter
public class TrackPlayCommand {

    Integer trackId;
    Integer albumId;

    @Builder
    public TrackPlayCommand(Integer trackId, Integer albumId) {
        this.trackId = trackId;
        this.albumId = albumId;
    }
}
