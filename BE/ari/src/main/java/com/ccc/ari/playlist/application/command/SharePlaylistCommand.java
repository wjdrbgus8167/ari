package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SharePlaylistCommand {

    Integer playlistId;
    Integer memberId;

    @Builder
    public SharePlaylistCommand(Integer playlistId, Integer memberId) {
        this.playlistId = playlistId;
        this.memberId = memberId;
    }
}
