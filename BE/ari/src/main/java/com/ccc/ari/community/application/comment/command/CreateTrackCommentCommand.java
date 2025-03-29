package com.ccc.ari.community.application.comment.command;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CreateTrackCommentCommand {

    private final Integer trackId;
    private final Integer memberId;
    private final String content;
    private final String contentTimestamp;
}
