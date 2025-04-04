package com.ccc.ari.playlist.infrastructure.adapter;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.playlist.application.service.PlaylistService;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.infrastructure.repository.playlist.JpaPlaylistRepository;
import com.ccc.ari.playlist.mapper.PlaylistMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;


@Component
@RequiredArgsConstructor
public class PlaylistClientImpl implements PlaylistClient {

    private final JpaPlaylistRepository jpaPlaylistRepository;
    private final PlaylistService playlistService;
    private final PlaylistMapper mapper;
    private final PlaylistMapper playlistMapper;
    @Override
    public Playlist getPlaylistById(Integer playlistId) {
        PlaylistEntity playlistEntity = jpaPlaylistRepository.findById(playlistId)
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));

        return playlistMapper.toDto(playlistEntity);
    }

    @Override
    public List<PlaylistEntity> getPlayListAllByMemberId(Integer memberId) {

        List<PlaylistEntity> list =jpaPlaylistRepository.findAllByMember_MemberId(memberId);

        return list;
    }

    @Override
    public List<Playlist> getPublicPlalList(boolean publicYn) {

        List<Playlist> playList =  playlistService.getPublicPlaylists();

        return playList;
    }

    @Override
    public void savePlaylist(PlaylistEntity playlist) {

        jpaPlaylistRepository.save(playlist);
    }

    @Override
    public void deletePlaylist(Integer playlistId) {
        jpaPlaylistRepository.deleteById(playlistId);
    }

    @Override
    public PlaylistEntity getPlaylistDetailById(Integer playlistId) {
        return jpaPlaylistRepository.findById(playlistId)
                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));
    }

    // 플레이리스트 공유 수 가장 높은 5개
    @Override
    public List<PlaylistEntity> getTop5MostSharedPlaylists() {

        return jpaPlaylistRepository.findTop5ByPublicYnTrueOrderByShareCountDesc();
    }
}
