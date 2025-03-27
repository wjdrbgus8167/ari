package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GetPlaylistCommand {

    Integer memberId;

    @Builder
    public GetPlaylistCommand(Integer memberId) {
        this.memberId = memberId;
    }
}
