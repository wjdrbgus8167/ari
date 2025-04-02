package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class DeletePlaylistTrackCommand {
    Integer playlistId;
    Integer trackId;

    @Builder
    public DeletePlaylistTrackCommand(Integer playlistId, Integer trackId) {
        this.playlistId = playlistId;
        this.trackId = trackId;
    }

    public static DeletePlaylistTrackCommand toCommand(Integer playlistId, Integer trackId) {
       return DeletePlaylistTrackCommand.builder()
               .playlistId(playlistId)
               .trackId(trackId)
               .build();
    }
}
