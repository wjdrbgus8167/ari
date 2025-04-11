package com.ccc.ari.playlist.ui.request;

import com.ccc.ari.playlist.application.command.SharePlaylistCommand;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SharePlaylistRequest {
    Integer playlistId;

    @Builder
    public SharePlaylistRequest(Integer playlistId) {
        this.playlistId = playlistId;
    }

    public SharePlaylistCommand requestToCommand(Integer memberId) {
        return SharePlaylistCommand.builder()
                .playlistId(playlistId)
                .memberId(memberId)
                .build();
    }
}
