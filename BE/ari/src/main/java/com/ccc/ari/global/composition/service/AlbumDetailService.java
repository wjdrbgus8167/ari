package com.ccc.ari.global.composition.service;

import com.ccc.ari.community.domain.comment.entity.AlbumComment;
import com.ccc.ari.community.domain.comment.client.AlbumCommentClient;
import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.client.LikeClient;
import com.ccc.ari.community.domain.rating.client.RatingClient;
import com.ccc.ari.global.composition.response.AlbumDetailResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.music.domain.track.TrackDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

/*
    앨범 상세 조회 Service 구현
 */
@Service
@RequiredArgsConstructor
public class AlbumDetailService {

    private final AlbumClient albumClient;
    private final TrackClient trackClient;
    private final AlbumCommentClient albumCommentClient;
    private final MemberClient memberClient;
    private final LikeClient likeClient;
    private final RatingClient ratingClient;

    public AlbumDetailResponse getAlbumDetail(Integer albumId,Integer memberId) {

        // 1. 앨범 정보 조회
        AlbumDto album = albumClient.getAlbumById(albumId);
        boolean albumLikedYn = likeClient.isLiked(albumId,memberId, LikeType.ALBUM);

        // 1-1. 앨범 평점 조회
        BigDecimal rating = ratingClient.getRating(albumId);

        // 2. 앨범에 포함된 트랙 목록 조회
        List<TrackDto> trackList = trackClient.getTracksByAlbumId(albumId);

        // 3.앨범 댓글들 조회
        List<AlbumComment> albumComments = albumCommentClient.getAlbumCommentsByAlbumId(albumId);

        // 4. 트랙 리스트
        List<AlbumDetailResponse.TrackDetail> tracks = trackList.stream()
                .map(track -> AlbumDetailResponse.TrackDetail.builder()
                        .trackId(track.getTrackId())
                        .trackTitle(track.getTitle())
                        .composer(track.getComposer())
                        .lyricist(track.getLyricist())
                        .lyric(track.getLyrics())
                        .trackNumber(track.getTrackNumber())
                        .trackLikeCount(track.getTrackLikeCount())
                        .trackFileUrl(track.getTrackFileUrl())
                        .build())
                .toList();

        // 5. 앨범 댓글 리스트
        List<AlbumDetailResponse.AlbumComment> comments = albumComments.stream()
                .map(comment -> AlbumDetailResponse.AlbumComment.builder()
                        .commentId(comment.getCommentId())
                        .memberId(comment.getMemberId())
                        .nickname(memberClient.getNicknameByMemberId(comment.getMemberId()))
                        .content(comment.getContent())
                        .createdAt(comment.getCreatedAt())
                        .build())
                .toList();

        //6. 앨범 상세 Response return
        return AlbumDetailResponse.builder()
                .albumId(album.getAlbumId())
                .albumTitle(album.getTitle())
                .artist(album.getArtist())
                .artistId(album.getMemberId())
                .description(album.getDescription())
                .genreName(album.getGenreName())
                .coverImageUrl(album.getCoverImageUrl())
                .releasedAt(album.getReleasedAt())
                .albumLikeCount(album.getAlbumLikeCount())
                .albumCommentCount(comments.size())
                .albumLikedYn(albumLikedYn)
                .albumRating(rating)
                .tracks(tracks)
                .albumComments(comments)
                .build();
    }
}
