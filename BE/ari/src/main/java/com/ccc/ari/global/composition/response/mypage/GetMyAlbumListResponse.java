package com.ccc.ari.global.composition.response.mypage;


import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class GetMyAlbumListResponse {

        private Integer albumId;
        private String albumTitle;
        private String coverImageUrl;
        private String description;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
        private LocalDateTime releasedAt;
        private String genre;
        private Integer memberId;
        private String artist;
        private Integer trackCount;

        @Builder
        public GetMyAlbumListResponse(Integer albumId, String albumTitle, String coverImageUrl, String description
                , LocalDateTime releasedAt, String genre, Integer memberId, String artist, Integer trackCount) {
            this.albumId = albumId;
            this.albumTitle = albumTitle;
            this.coverImageUrl = coverImageUrl;
            this.description = description;
            this.releasedAt = releasedAt;
            this.genre = genre;
            this.memberId = memberId;
            this.artist = artist;
            this.trackCount = trackCount;

        }

}
