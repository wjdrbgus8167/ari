package com.ccc.ari.community.application.fantalk.command;

import lombok.Builder;
import lombok.Getter;
import org.springframework.web.multipart.MultipartFile;

@Getter
public class CreateFantalkCommand {

    private final Integer memberId;
    private final Integer fantalkChannelId;
    private final Integer trackId;
    private final String content;
    private final MultipartFile fantalkImage;

    @Builder
    public CreateFantalkCommand(Integer memberId, Integer fantalkChannelId, Integer trackId, String content, MultipartFile fantalkImage) {
        this.memberId = memberId;
        this.fantalkChannelId = fantalkChannelId;
        this.trackId = trackId;
        this.content = content;
        this.fantalkImage = fantalkImage;
    }
}
