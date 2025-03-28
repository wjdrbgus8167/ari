package com.ccc.ari.community.application.like.command;

import lombok.Builder;
import lombok.Getter;

@Getter
public class LikeCommand {

    private final Integer albumId;
    private final Integer memberId;
    private final Boolean activateYn;

    @Builder
    public LikeCommand(Integer albumId, Integer memberId, Boolean activateYn) {
        this.albumId = albumId;
        this.memberId = memberId;
        this.activateYn = activateYn;
    }
}
