package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetPlaylistDetailCommand {
    private Integer playlistId;

    @Builder
    public GetPlaylistDetailCommand(Integer playlistId) {
        this.playlistId = playlistId;
    }
}
