package com.ccc.ari.music.domain.track;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TrackDto {
    private Integer trackId;
    private String title;
    private String composer;
    private String lyricist;
    private String lyrics;
    private Integer trackNumber;
    private String trackFileUrl;
    private Integer trackLikeCount;
    private Integer albumId;
    // TODO :추후 genre 구현되고 수정해야됨.
    private String gereName;
}
