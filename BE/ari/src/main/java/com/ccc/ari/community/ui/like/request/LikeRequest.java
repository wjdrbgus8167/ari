package com.ccc.ari.community.ui.like.request;

import com.ccc.ari.community.application.like.command.LikeCommand;
import lombok.Getter;

@Getter
public class LikeRequest {
    private Boolean activateYn;

    /**
     * Request -> Command 변환 메서드
     */
    public LikeCommand toCommand(Integer albumId, Integer memberId) {
        return LikeCommand.builder()
                .albumId(albumId)
                .memberId(memberId)
                .activateYn(this.activateYn)
                .build();
    }
}
