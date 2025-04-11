package com.ccc.ari.community.ui.comment.request;

import com.ccc.ari.community.application.comment.command.CreateAlbumCommentCommand;
import com.ccc.ari.community.application.comment.command.CreateTrackCommentCommand;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class CreateTrackCommentRequest {

    private String content;
    private String contentTimestamp;

    /**
     * Request -> Command 변환 메서드
     */
    public CreateTrackCommentCommand toCommand(Integer trackId, Integer memberId, String content, String contentTimestamp) {
        return CreateTrackCommentCommand.builder()
                .trackId(trackId)
                .memberId(memberId)
                .content(this.content)
                .contentTimestamp(this.contentTimestamp)
                .build();
    }
}
