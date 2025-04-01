package com.ccc.ari.community.application.like.command;

import lombok.Builder;
import lombok.Getter;

@Getter
public class LikeStatusCommand {

    private final Integer targetId;
    private final Integer memberId;

    @Builder
    public LikeStatusCommand(Integer targetId, Integer memberId) {
        this.targetId = targetId;
        this.memberId = memberId;
    }
}
