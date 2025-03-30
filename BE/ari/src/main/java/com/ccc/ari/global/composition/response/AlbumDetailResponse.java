package com.ccc.ari.global.composition.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import java.time.LocalDateTime;
import java.util.List;

/*
  앨범 상세 Response
  아직 rating이 없어서 rating 구현 후 추가 예정
 */
@Getter
@Builder
public class AlbumDetailResponse {

    private final Integer albumId;
    private final String albumTitle;
    private final String artist;
    private final String description;
    private final String genreName;
    private final String coverImageUrl;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private final LocalDateTime releasedAt;

    private final Integer albumLikeCount;
    private final Integer albumCommentCount;

    private final List<TrackDetail> tracks;
    private final List<AlbumComment> albumComments;

    @Getter
    @Builder
    public static class TrackDetail {
        private final Integer trackId;
        private final String trackTitle;
        private final String composer;
        private final String lyricist;
        private final String lyric;
        private final Integer trackNumber;
        private final Integer trackLikeCount;
        private final String trackFileUrl;
    }

    @Getter
    @Builder
    public static class AlbumComment {
        private final Integer commentId;
        private final Integer memberId;
        private final String nickname;
        private final String content;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private final LocalDateTime createdAt;
    }

}
