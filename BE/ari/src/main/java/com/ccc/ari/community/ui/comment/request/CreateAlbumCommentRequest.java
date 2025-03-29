package com.ccc.ari.community.ui.comment.request;

import com.ccc.ari.community.application.comment.command.CreateAlbumCommentCommand;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class CreateAlbumCommentRequest {

    private String content;

    /**
     * Request -> Command 변환 메서드
     */
    public CreateAlbumCommentCommand toCommand(Integer albumId, Integer memberId, String content) {
        return CreateAlbumCommentCommand.builder()
                .albumId(albumId)
                .memberId(memberId)
                .content(this.content)
                .build();
    }
}
