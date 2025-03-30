package com.ccc.ari.global.composition.service;

import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.community.domain.comment.entity.TrackComment;
import com.ccc.ari.global.composition.infrastructure.StreamingLogClientImpl;
import com.ccc.ari.global.composition.infrastructure.TrackCommentClient;
import com.ccc.ari.global.composition.response.TrackDetailResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/*
 트랙 상세 정보 조회 Service
 */
@Service
@RequiredArgsConstructor
public class TrackDetailService {

    private final TrackClient trackClient;
    private final TrackCommentClient trackCommentClient;
    private final MemberClient memberClient;
    private final StreamingLogClientImpl streamingLogClient;

    public TrackDetailResponse getTrackDetail(Integer trackId) {

        // 1. 트랙 조회
        TrackDto track = trackClient.getTrackById(trackId);

        // 2. 트랙 댓글 조회
        List<TrackComment> trackComments = trackCommentClient.getTrackCommentsByTrackId(track.getTrackId());

        // 3. 트랙 스트리밍 집계 데이터 조회

        // 4. 트랙 댓글 리스트
        List<TrackDetailResponse.TrackComment> comments = trackComments.stream()
                .map(comment -> TrackDetailResponse.TrackComment.builder()
                        .commentId(comment.getCommentId())
                        .memberId(comment.getMemberId())
                        .nickname(memberClient.getNicknameByMemberId(comment.getMemberId()))
                        .content(comment.getContent())
                        .timestamp(comment.getContentTimestamp())
                        .createdAt(comment.getCreatedAt())
                        .build())
                .toList();

        List<StreamingLog> logs = streamingLogClient.getStreamingLog(track.getTrackId());

        List<TrackDetailResponse.StreamingLogData> streamingLogData = logs.stream()
                .map(streamingLog -> TrackDetailResponse.StreamingLogData.builder()
                        .name(streamingLog.getMemberNickname())
                        .datetime(streamingLog.timestampToString())
                        .build())
                .toList();

        return TrackDetailResponse.builder()
                .trackId(track.getTrackId())
                .trackTitle(track.getTitle())
                .composer(track.getComposer())
                .lyricist(track.getLyricist())
                .lyric(track.getLyrics())
                .trackNumber(track.getTrackNumber())
                .trackLikeCount(track.getTrackLikeCount())
                .genreName(track.getGereName())
                .trackFileUrl(track.getTrackFileUrl())
                .trackComments(comments)
                .trackCommentCount(comments.size())
                .trackStreamingCount(streamingLogData.size())
                .trackLogs(streamingLogData)
                .build();
    }


}
