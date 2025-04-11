package com.ccc.ari.playlist.ui.response;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class CreatePlaylistResponse {
    Integer playlistId;
    String playlistTitle;
    boolean publicYn;

    @Builder
    public CreatePlaylistResponse(Integer playlistId,String playlistTitle, boolean publicYn) {
        this.playlistId = playlistId;
        this.playlistTitle = playlistTitle;
        this.publicYn = publicYn;
    }
}
