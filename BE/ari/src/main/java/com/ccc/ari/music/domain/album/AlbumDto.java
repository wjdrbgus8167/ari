package com.ccc.ari.music.domain.album;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class AlbumDto {
    private Integer albumId;
    private String title;
    private String artist; // 앨범의 member nickname
    private String description;
    private String genreName;
    private String coverImageUrl;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime releasedAt;

    private Integer albumLikeCount;

}
