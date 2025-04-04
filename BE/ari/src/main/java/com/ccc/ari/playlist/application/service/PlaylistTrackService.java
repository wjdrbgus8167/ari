package com.ccc.ari.playlist.application.service;

import com.ccc.ari.playlist.application.command.DeletePlaylistTrackCommand;
import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import com.ccc.ari.playlist.infrastructure.repository.playlisttrack.JpaPlaylistTrackRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaylistTrackService {

    private final JpaPlaylistTrackRepository playlistTrackRepository;

    // 플레이리스트 내에 트랙 삭제
    @Transactional
    public void deletePlaylistTrack(DeletePlaylistTrackCommand command) {

        playlistTrackRepository.deleteByPlaylist_PlaylistIdAndTrack_TrackId(command.getPlaylistId(), command.getTrackId());

    }

    @Transactional
    public Integer getTrackCount(Integer playlistId) {
        List<PlaylistTrackEntity> entities = playlistTrackRepository.findAllByPlaylist_PlaylistId(playlistId);

        return entities.size();
    }

    public List<PlaylistTrackEntity> getPlaylistTracks(Integer playlistId) {
        return playlistTrackRepository.findAllByPlaylist_PlaylistId(playlistId);
    }
}
