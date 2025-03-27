package com.ccc.ari.playlist.ui.request;

import com.ccc.ari.playlist.application.command.CreatePlaylistCommand;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class CreatePlaylistRequest {

    String playlistTitle;

    @Builder
    public CreatePlaylistRequest(String playlistTitle) {
        this.playlistTitle = playlistTitle;
    }
    public CreatePlaylistCommand requestToCommand(String playlistTitle,Integer memberId) {

        return CreatePlaylistCommand.builder()
                .playlistTitle(playlistTitle)
                .memberId(memberId)
                .build();
    }
}
