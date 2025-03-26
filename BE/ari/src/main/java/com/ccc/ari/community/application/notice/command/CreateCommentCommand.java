package com.ccc.ari.community.application.notice.command;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CreateCommentCommand {

    private final Integer noticeId;
    private final Integer memberId;
    private final String content;
}
