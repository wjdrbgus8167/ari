package com.ccc.ari.playlist.application.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.playlist.application.command.CreatePlaylistCommand;
import com.ccc.ari.playlist.application.command.PublicPlaylistCommand;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlisttrack.client.PlaylistTrackClient;
import com.ccc.ari.playlist.infrastructure.repository.playlist.JpaPlaylistRepository;
import com.ccc.ari.playlist.mapper.PlaylistMapper;
import com.ccc.ari.playlist.ui.response.CreatePlaylistResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlaylistService {

    private final JpaPlaylistRepository jpaPlaylistRepository;
    private final PlaylistMapper playlistMapper;

    // 플레이리스트 생성
    @Transactional
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


    // 플레이리스트 공개/ 비공개 전환
    @Transactional
    public void publicPlaylist(PublicPlaylistCommand command) {
        PlaylistEntity playlist = jpaPlaylistRepository.findById(command.getPlaylistId())
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));

        playlist.updatePublicYn(command.isPublicYn());
    }


    // 공개된 플레이리스트 조회
    public List<Playlist> getPublicPlaylists() {

        List<PlaylistEntity> list = jpaPlaylistRepository.findAllByPublicYn(true)
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));

        return list.stream()
                .map(playlistMapper::toDto)
                .collect(Collectors.toList());
    }

    public List<PlaylistEntity> getTop5MostSharedPlaylists() {

        return jpaPlaylistRepository.findTop5ByOrderByShareCountDesc();
    }
}
