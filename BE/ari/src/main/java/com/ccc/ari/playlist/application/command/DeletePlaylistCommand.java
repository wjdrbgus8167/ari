package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class DeletePlaylistCommand {
    Integer playlistId;
    Integer memberId;

    @Builder
    public DeletePlaylistCommand(Integer playlistId,Integer memberId) {
        this.playlistId = playlistId;
        this.memberId = memberId;
    }
}
