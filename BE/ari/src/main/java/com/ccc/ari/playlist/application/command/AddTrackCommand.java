package com.ccc.ari.playlist.application.command;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class AddTrackCommand {

    Integer playlistId;
    List<Integer> trackIds;

    @Builder
    public AddTrackCommand(Integer playlistId, List<Integer> trackIds) {
        this.playlistId = playlistId;
        this.trackIds = trackIds;
    }


}
