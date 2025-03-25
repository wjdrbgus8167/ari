package com.ccc.ari.community.ui.fantalk.request;

import com.ccc.ari.community.application.fantalk.command.CreateFantalkCommand;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Getter
@NoArgsConstructor
public class CreateFantalkRequest {

    private String content;
    private Integer trackId;

    /**
     * Request -> Command 변환 메서드
     */
    public CreateFantalkCommand toCommand(Integer memberId, Integer fantalkChannelId, MultipartFile fantalkImage) {
        return CreateFantalkCommand.builder()
                .memberId(memberId)
                .fantalkChannelId(fantalkChannelId)
                .content(this.content)
                .trackId(this.trackId)
                .fantalkImage(fantalkImage)
                .build();
    }
}
