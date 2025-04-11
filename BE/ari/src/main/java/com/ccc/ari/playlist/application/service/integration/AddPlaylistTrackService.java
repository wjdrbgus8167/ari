package com.ccc.ari.playlist.application.service.integration;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.music.infrastructure.repository.track.JpaTrackRepository;
import com.ccc.ari.playlist.application.command.AddTrackCommand;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.domain.service.ValidateDuplicateTrackService;
import com.ccc.ari.playlist.domain.vo.TrackOrder;
import com.ccc.ari.playlist.infrastructure.repository.playlist.JpaPlaylistRepository;
import com.ccc.ari.playlist.mapper.PlaylistMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;

@Component
@RequiredArgsConstructor
public class AddPlaylistTrackService {

    private final ValidateDuplicateTrackService validateDuplicateTrackService;
    private final PlaylistClient playlistClient;
    private final PlaylistMapper playlistMapper;
    private final TrackClient trackClient;
    private final JpaPlaylistRepository jpaPlaylistRepository;
    private final JpaTrackRepository jpaTrackRepository;
    @Transactional
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



}
