package com.ccc.ari.community.application.notice.command;

import lombok.Builder;
import lombok.Getter;
import org.springframework.web.multipart.MultipartFile;

@Getter
@Builder
public class CreateNoticeCommand {

    private final Integer artistId;
    private final String noticeContent;
    private final MultipartFile noticeImage;
}
