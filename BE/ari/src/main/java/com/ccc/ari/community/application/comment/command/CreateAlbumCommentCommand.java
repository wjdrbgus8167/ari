package com.ccc.ari.community.application.comment.command;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CreateAlbumCommentCommand {

    private final Integer albumId;
    private final Integer memberId;
    private final String content;
}
