package com.ccc.ari.playlist.ui.request;

import com.ccc.ari.playlist.application.command.CreatePlaylistCommand;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class CreatePlaylistRequest {

    String playlistTitle;
    boolean publicYn;

    @Builder
    public CreatePlaylistRequest(String playlistTitle,boolean publicYn) {

        this.playlistTitle = playlistTitle;
        this.publicYn = publicYn;
    }
    public CreatePlaylistCommand requestToCommand(Integer memberId) {

        return CreatePlaylistCommand.builder()
                .playlistTitle(playlistTitle)
                .memberId(memberId)
                .publicYn(publicYn)
                .build();
    }
}
