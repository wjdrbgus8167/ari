package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class PublicPlaylistCommand {

    private Integer playlistId;
    private Integer memberId;

    @Builder
    public PublicPlaylistCommand(Integer playlistId, Integer memberId) {
        this.playlistId = playlistId;
        this.memberId = memberId;

    }

}
