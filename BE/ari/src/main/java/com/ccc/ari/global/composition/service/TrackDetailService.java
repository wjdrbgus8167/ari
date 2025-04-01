package com.ccc.ari.global.composition.service;

import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.community.domain.comment.entity.TrackComment;
import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.client.LikeClient;
import com.ccc.ari.global.composition.infrastructure.StreamingLogClientImpl;
import com.ccc.ari.community.domain.comment.client.TrackCommentClient;
import com.ccc.ari.global.composition.response.TrackDetailResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
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

    private final AlbumClient albumClient;
    private final TrackClient trackClient;
    private final TrackCommentClient trackCommentClient;
    private final MemberClient memberClient;
    private final StreamingLogClientImpl streamingLogClient;
    private final LikeClient likeClient;
    public TrackDetailResponse getTrackDetail(Integer trackId,Integer memberId) {

        // 1. 트랙, 앨범, 멤버 조회
        TrackDto track = trackClient.getTrackById(trackId);
        AlbumDto album = albumClient.getAlbumById(track.getAlbumId());
        MemberDto member  = memberClient.getMemberByMemberId(album.getMemberId());
        boolean trackLikedYn = likeClient.isLiked(trackId,memberId, LikeType.TRACK);
        // 2. 트랙 댓글 조회
        List<TrackComment> trackComments = trackCommentClient.getTrackCommentsByTrackId(track.getTrackId());

        // 3. 트랙 댓글 리스트
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

        return TrackDetailResponse.builder()
                .trackId(track.getTrackId())
                .trackTitle(track.getTitle())
                .albumTitle(album.getTitle())
                .artist(member.getNickname())
                .composer(track.getComposer())
                .lyricist(track.getLyricist())
                .lyric(track.getLyrics())
                .trackNumber(track.getTrackNumber())
                .trackLikeCount(track.getTrackLikeCount())
                .trackLikedYn(trackLikedYn)
                .genreName(track.getGereName())
                .trackFileUrl(track.getTrackFileUrl())
                .trackComments(comments)
                .trackCommentCount(comments.size())
                .build();
    }


}
