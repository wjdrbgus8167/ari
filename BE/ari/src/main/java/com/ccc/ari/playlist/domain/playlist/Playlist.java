package com.ccc.ari.playlist.domain.playlist;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class Playlist {

    private Integer playlistId;
    private String playListTitle;
    private Integer memberId;
    private boolean publicYn;
    private LocalDateTime createdAt;
    private Integer shareCount;

    @Builder
    public Playlist(Integer playlistId,String playListTitle,Integer memberId,boolean publicYn
            ,LocalDateTime createdAt,Integer shareCount) {
        this.playlistId = playlistId;
        this.playListTitle = playListTitle;
        this.memberId = memberId;
        this.publicYn = publicYn;
        this.createdAt = createdAt;
        this.shareCount = shareCount;
    }

}
