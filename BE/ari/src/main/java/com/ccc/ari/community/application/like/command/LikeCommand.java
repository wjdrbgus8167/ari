package com.ccc.ari.community.application.like.command;

import lombok.Builder;
import lombok.Getter;

@Getter
public class LikeCommand {

    private final Integer targetId;
    private final Integer memberId;
    private final Boolean activateYn;

    @Builder
    public LikeCommand(Integer targetId, Integer memberId, Boolean activateYn) {
        this.targetId = targetId;
        this.memberId = memberId;
        this.activateYn = activateYn;
    }
}
