package com.ccc.ari.playlist.application.service.integration;

import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.playlist.application.command.GetPlaylistCommand;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.domain.playlisttrack.client.PlaylistTrackClient;
import com.ccc.ari.playlist.domain.sharedplaylist.SharedPlaylistEntity;
import com.ccc.ari.playlist.domain.sharedplaylist.client.SharedPlaylistClient;
import com.ccc.ari.playlist.infrastructure.repository.sharedplaylist.JpaSharedPlaylistRepository;
import com.ccc.ari.playlist.ui.response.GetPlayListResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
@Slf4j
public class GetPlaylistService {

    private final PlaylistClient playlistClient;
    private final SharedPlaylistClient sharedPlaylistClient;
    private final JpaSharedPlaylistRepository jpaSharedPlaylistRepository;
    private final PlaylistTrackClient playlistTrackClient;
    private final AlbumClient albumClient;
    private final TrackClient trackClient;

    //플레이리스트 조회(사용자 본인)
    @Transactional
    public GetPlayListResponse getPlaylist(GetPlaylistCommand command) {
        log.info("Get playlist:{}", command);
        // 자신이 직접 만든 플레이리스트와 퍼온 플레이리스트(SharedPlaylist)를 모두 조회하여 가져옴
        //List<PlaylistEntity> myPlaylists = jpaPlaylistRepository.findAllByMember_MemberId(command.getMemberId());
        List<SharedPlaylistEntity> sharedPlaylists = jpaSharedPlaylistRepository.findAllByMember_MemberId(command.getMemberId());
        log.info("공유한거:{}", sharedPlaylists.get(0).getSharedPlaylistId());
        List<PlaylistEntity> myPlaylists  = playlistClient.getPlayListAllByMemberId(command.getMemberId());
        log.info("내꺼:{}", myPlaylists.get(0).getPlaylistId());

        // 직접 만든 플레이리스트 → PlaylistResponse로 변환
        Stream<GetPlayListResponse.PlaylistResponse> myPlaylistStream = myPlaylists.stream()
                .map(playlist -> GetPlayListResponse.PlaylistResponse.builder()
                        .playlistId(playlist.getPlaylistId())
                        .playlistTitle(playlist.getPlaylistTitle())
                        .publicYn(playlist.isPublicYn())
                        .trackCount(playlist.getTracks().size())
                        .coverImageUrl(
                                !playlist.getTracks().isEmpty()
                                        ? playlist.getTracks().get(0).getTrack().getAlbum().getCoverImageUrl()
                                        : null
                        )
                        .artist(
                                !playlist.getTracks().isEmpty()
                                        ? playlist.getTracks().get(0).getTrack().getAlbum().getMember().getNickname()
                                        : null
                        )
                        .build());

        // 퍼온 플레이리스트 → PlaylistResponse로 변환
        Stream<GetPlayListResponse.PlaylistResponse> sharedPlaylistStream = sharedPlaylists.stream()
                .map(shared -> {
                    PlaylistEntity playlist = shared.getPlaylist();
                    return GetPlayListResponse.PlaylistResponse.builder()
                            .playlistId(playlist.getPlaylistId())
                            .playlistTitle(playlist.getPlaylistTitle())
                            .trackCount(playlist.getTracks().size())
                            .coverImageUrl(
                                    !playlist.getTracks().isEmpty()
                                            ? playlist.getTracks().get(0).getTrack().getAlbum().getCoverImageUrl()
                                            : null
                            )
                            .artist(
                                    !playlist.getTracks().isEmpty()
                                            ? playlist.getTracks().get(0).getTrack().getAlbum().getMember().getNickname()
                                            : null
                            )
                            .build();
                });

        // 두 개의 목록을 한 번에 사용자에게 return.
        List<GetPlayListResponse.PlaylistResponse> playlistResponses = Stream.concat(myPlaylistStream, sharedPlaylistStream)
                .toList();

        return GetPlayListResponse.builder()
                .playlists(playlistResponses)
                .build();

    }
}
