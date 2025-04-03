package com.ccc.ari.playlist.application.composition;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.infrastructure.repository.member.JpaMemberRepository;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.infrastructure.repository.track.JpaTrackRepository;
import com.ccc.ari.playlist.application.command.GetPlaylistDetailCommand;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import com.ccc.ari.playlist.domain.sharedplaylist.SharedPlaylistEntity;
import com.ccc.ari.playlist.infrastructure.JpaPlaylistRepository;
import com.ccc.ari.playlist.infrastructure.JpaSharedPlaylistRepository;
import com.ccc.ari.playlist.ui.response.GetPlaylistDetailResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaylistCompositionService {

    private final JpaPlaylistRepository jpaPlaylistRepository;
    private final JpaTrackRepository jpaTrackRepository;
    private final JpaMemberRepository jpaMemberRepository;
    private final JpaSharedPlaylistRepository jpaSharedPlaylistRepository;

    // 플레이리스트 상세조회
    public GetPlaylistDetailResponse getPlaylistDetailComposition(GetPlaylistDetailCommand command) {
        PlaylistEntity playlist = jpaPlaylistRepository.findById(command.getPlaylistId())
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));

        List<PlaylistTrackEntity> playlistTracks = playlist.getTracks()
                .stream()
                .sorted(Comparator.comparingInt(PlaylistTrackEntity::getTrackOrder))
                .toList();

        List<GetPlaylistDetailResponse.TrackDetail> tracks = playlistTracks.stream()
                .map(playlistTrack -> {
                    TrackEntity track = jpaTrackRepository.findById(playlistTrack.getTrack().getTrackId())
                            .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_TRACK_NOT_FOUND));

                    return GetPlaylistDetailResponse.TrackDetail.builder()
                            .trackOrder(playlistTrack.getTrackOrder())
                            .trackId(track.getTrackId())
                            .artist(track.getAlbum().getMember().getNickname())
                            .coverImageUrl(track.getAlbum().getCoverImageUrl())
                            .composer(track.getComposer())
                            .lyricist(track.getLyricist())
                            .lyrics(track.getLyrics())
                            .trackFileUrl(track.getTrackFileUrl())
                            .trackLikeCount(track.getTrackLikeCount())
                            .trackNumber(track.getTrackNumber())
                            .trackTitle(track.getTrackTitle())
                            .albumId(track.getAlbum().getAlbumId())
                            .build();
                })
                .toList();

        return GetPlaylistDetailResponse.builder()
                .tracks(tracks)
                .build();
    }

    // 플레이리스트 퍼오기
    @Transactional
    public void sharePlaylistComposition(PlaylistEntity playlist, Integer memberId) {
        // 회원 조회
        MemberEntity member = jpaMemberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(ErrorCode.MEMBER_NOT_FOUND));

        // 퍼가기 엔티티 생성 및 저장
        SharedPlaylistEntity shared = SharedPlaylistEntity.builder()
                .playlist(playlist)
                .member(member)
                .createdAt(LocalDateTime.now())
                .build();

        jpaSharedPlaylistRepository.save(shared);

        // 공유 수 증가 (도메인 책임)
        playlist.increaseShareCount();
    }
}