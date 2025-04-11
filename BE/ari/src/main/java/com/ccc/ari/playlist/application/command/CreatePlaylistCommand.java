package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class CreatePlaylistCommand {
    String playlistTitle;
    Integer memberId;
    boolean publicYn;

    @Builder
    public CreatePlaylistCommand(String playlistTitle, Integer memberId, boolean publicYn) {
        this.playlistTitle = playlistTitle;
        this.memberId = memberId;
        this.publicYn = publicYn;

    }
}
