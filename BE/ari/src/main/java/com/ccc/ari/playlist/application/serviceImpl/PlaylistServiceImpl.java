package com.ccc.ari.playlist.application.serviceImpl;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.infrastructure.repository.track.JpaTrackRepository;
import com.ccc.ari.playlist.application.PlaylistService;
import com.ccc.ari.playlist.application.command.*;
import com.ccc.ari.playlist.application.composition.PlaylistCompositionService;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.service.ValidateDuplicateTrackService;
import com.ccc.ari.playlist.domain.sharedplaylist.SharedPlaylistEntity;
import com.ccc.ari.playlist.domain.vo.TrackOrder;
import com.ccc.ari.playlist.infrastructure.JpaPlaylistRepository;
import com.ccc.ari.playlist.infrastructure.JpaPlaylistTrackRepository;
import com.ccc.ari.playlist.infrastructure.JpaSharedPlaylistRepository;
import com.ccc.ari.playlist.mapper.PlaylistMapper;
import com.ccc.ari.playlist.ui.response.CreatePlaylistResponse;
import com.ccc.ari.playlist.ui.response.GetPlayListResponse;
import com.ccc.ari.playlist.ui.response.GetPlaylistDetailResponse;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Stream;

@AllArgsConstructor
@Service
public class PlaylistServiceImpl implements PlaylistService {

    private final JpaPlaylistRepository jpaPlaylistRepository;
    private final JpaTrackRepository jpaTrackRepository;
    private final JpaSharedPlaylistRepository jpaSharedPlaylistRepository;
    private final PlaylistMapper playlistMapper;
    private final PlaylistCompositionService playlistCompositionService;
    private final JpaPlaylistTrackRepository jpaPlaylistTrackRepository;
    private final ValidateDuplicateTrackService validateDuplicateTrackService;
    // 플레이리스트 생성
    @Override
    public CreatePlaylistResponse createPlaylist(CreatePlaylistCommand command) {

        Playlist playlist = Playlist.builder()
                .memberId(command.getMemberId())
                .playListTitle(command.getPlaylistTitle())
                .publicYn(command.isPublicYn())
                .build();

        PlaylistEntity savedPlaylist = jpaPlaylistRepository.save(playlistMapper.mapToEntity(playlist));

        return CreatePlaylistResponse.builder()
                .playlistId(savedPlaylist.getPlaylistId())
                .playlistTitle(savedPlaylist.getPlaylistTitle())
                .publicYn(savedPlaylist.isPublicYn())
                .build();
    }

    // 플레이리스트 트랙 추가
    @Transactional
    @Override
    public void addTrack(AddTrackCommand command) {

        validateDuplicateTrackService.validateDuplicateTracks(command.getTrackIds());

        PlaylistEntity playlist = jpaPlaylistRepository.findById(command.getPlaylistId())
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        // 1. 현재 최대 순서 계산
        TrackOrder currentMaxOrder = playlist.getTracks().stream()
                .map(track -> TrackOrder.from(track.getTrackOrder()))
                .max(Comparator.comparingInt(TrackOrder::getValue))
                .orElse(TrackOrder.from(0)); // 트랙이 없다면 0부터 시작

        // 2. 순서 증가시키면서 트랙 추가
        TrackOrder nextOrder = currentMaxOrder;

        // 추후에 refactoring 필요. music 도메인 침범(track).
        for (Integer trackId : command.getTrackIds()) {
            TrackEntity track = jpaTrackRepository.findById(trackId)
                    .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_TRACK_ADD_FAIL));

            nextOrder = nextOrder.next();
            playlist.addTrackIfNotExists(track, nextOrder.getValue());
        }

        jpaPlaylistRepository.save(playlist);
    }


    // 플레이리스트 내에 트랙 삭제
    @Transactional
    @Override
    public void deletePlaylistTrack(DeletePlaylistTrackCommand command) {

        jpaPlaylistTrackRepository.deleteByPlaylist_PlaylistIdAndTrack_TrackId(command.getPlaylistId(), command.getTrackId());

    }

    @Transactional
    @Override
    public void deletePlaylist(DeletePlaylistCommand command) {

        // 플레이리스트 먼저 조회
        PlaylistEntity playlist = jpaPlaylistRepository.findById(command.getPlaylistId())
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));

        // 사용자가 퍼왔던 플레이리스트를 먼저 조회.
        // 이유는 현재 플레이리시트 목록 조회의 경우 사용자가 공개된 플레이리스트를 SharedPlaylist를 통해 참조하여 가져오는 방식
        // 따라서 자신의 플레이리스트 목록을 조회했을 때의 플레이리스트 id를 받아 먼저 이 플레이리스트가 퍼온 플레이리스트인지 확인
        // 만약 퍼온 플레이리스트라면 SharedPlaylist에서 삭제(int 값은 그럼 1), 아니라면 내가 직접 만든 플레이리스트이므로
        int deletedSharedPlaylist =jpaSharedPlaylistRepository.deleteByMember_MemberIdAndPlaylist_PlaylistId(command.getMemberId(),command.getPlaylistId());

        // 여기서 삭제
        if(deletedSharedPlaylist==0){
            jpaPlaylistRepository.delete(playlist);
        }

    }

    //플레이리스트 조회(사용자 본인)
    @Transactional
    @Override
    public GetPlayListResponse getPlaylist(GetPlaylistCommand command) {

        // 자신이 직접 만든 플레이리스트와 퍼온 플레이리스트(SharedPlaylist)를 모두 조회하여 가져옴
        List<PlaylistEntity> myPlaylists = jpaPlaylistRepository.findAllByMember_MemberId(command.getMemberId());
        List<SharedPlaylistEntity> sharedPlaylists = jpaSharedPlaylistRepository.findAllByMember_MemberId(command.getMemberId());

        // 직접 만든 플레이리스트 → PlaylistResponse로 변환
        Stream<GetPlayListResponse.PlaylistResponse> myPlaylistStream = myPlaylists.stream()
                .map(playlist -> GetPlayListResponse.PlaylistResponse.builder()
                        .playlistId(playlist.getPlaylistId())
                        .playlistTitle(playlist.getPlaylistTitle())
                        .publicYn(playlist.isPublicYn())
                        .trackCount(playlist.getTracks().size())
                        .build());

        // 퍼온 플레이리스트 → PlaylistResponse로 변환
        Stream<GetPlayListResponse.PlaylistResponse> sharedPlaylistStream = sharedPlaylists.stream()
                .map(shared -> {
                    PlaylistEntity playlist = shared.getPlaylist();
                    return GetPlayListResponse.PlaylistResponse.builder()
                            .playlistId(playlist.getPlaylistId())
                            .playlistTitle(playlist.getPlaylistTitle())
                            .trackCount(playlist.getTracks().size())
                            .build();
                });

        // 두 개의 목록을 한 번에 사용자에게 return.
        List<GetPlayListResponse.PlaylistResponse> playlistResponses = Stream.concat(myPlaylistStream, sharedPlaylistStream)
                .toList();

        return GetPlayListResponse.builder()
                .playlists(playlistResponses)
                .build();
    }


    // 플레이리스트 상세 조회
    @Override
    public GetPlaylistDetailResponse getPlaylistDetail(GetPlaylistDetailCommand command) {

      GetPlaylistDetailResponse response = playlistCompositionService.getPlaylistDetailComposition(command);

        return response;
    }


    // 플레이리스트 퍼오기
    @Override
    @Transactional
    public void sharePlaylist(SharePlaylistCommand command) {

        // 퍼갈 원본 플레이리스트 조회
        PlaylistEntity sharedPlaylist = jpaPlaylistRepository.findById(command.getPlaylistId())
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));

        // 만약 이 플레이리스트가 비공개라면 에러 처리
        if (!sharedPlaylist.isPublicYn()) {
            throw new ApiException(ErrorCode.PLAYLIST_NOT_PUBLIC);
        }

        playlistCompositionService.sharePlaylistComposition(sharedPlaylist, command.getMemberId());

    }

    // 플레이리스트 공개로 전환
    @Override
    @Transactional
    public void publicPlaylist(PublicPlaylistCommand command) {
        PlaylistEntity playlist = jpaPlaylistRepository.findById(command.getPlaylistId())
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));

        playlist.updatePublicYn(command.isPublicYn());
    }
}
