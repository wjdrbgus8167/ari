package com.ccc.ari.music.application.command;

import lombok.Builder;
import lombok.Getter;

@Getter
public class TrackPlayCommand {

    Integer trackId;
    Integer albumId;
    Integer memberId;
    String nickname;

    @Builder
    public TrackPlayCommand(Integer trackId, Integer albumId, Integer memberId,String nickname) {
        this.trackId = trackId;
        this.albumId = albumId;
        this.memberId = memberId;
        this.nickname = nickname;
    }
}
