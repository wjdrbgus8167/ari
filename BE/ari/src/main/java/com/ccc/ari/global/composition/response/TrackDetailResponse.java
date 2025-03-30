package com.ccc.ari.global.composition.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

/*
    트랙 상세 페이지 조회 Response
 */
@Getter
@Builder
public class TrackDetailResponse {

    private final Integer trackId;
    private final String trackTitle;
    private final String composer;
    private final String lyricist;
    private final String lyric;
    private final Integer trackNumber;
    private final Integer trackLikeCount;
    private final String trackFileUrl;
    private final String genreName;
    private final Integer trackCommentCount;
    private final Integer trackStreamingCount;
    private final List<TrackComment> trackComments;
    private final List<StreamingLogData> trackLogs ;


    @Getter
    @Builder
    public static class TrackComment {
        private final Integer commentId;
        private final Integer memberId;
        private final String nickname;
        private final String content;
        private final String timestamp;
        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private final LocalDateTime createdAt;
    }

    @Getter
    @Builder
    public static class StreamingLogData {
        String name;
        String datetime;
    }
}
