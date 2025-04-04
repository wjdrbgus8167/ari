package com.ccc.ari.global.composition.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.music.infrastructure.repository.track.JpaTrackRepository;
import com.ccc.ari.playlist.application.command.GetPlaylistDetailCommand;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import com.ccc.ari.playlist.infrastructure.repository.playlist.JpaPlaylistRepository;
import com.ccc.ari.playlist.mapper.PlaylistMapper;
import com.ccc.ari.playlist.ui.response.GetPlaylistDetailResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.sound.midi.Track;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class GetPlaylistDetailService {

    private final TrackClient trackClient;
    private final PlaylistClient playlistClient;

    // 플레이리스트 상세조회
    public GetPlaylistDetailResponse getPlaylistDetail(GetPlaylistDetailCommand command) {

        PlaylistEntity playlist = playlistClient.getPlaylistDetailById(command.getPlaylistId());
        List<PlaylistTrackEntity> playlistTracks = playlist.getTracks()
                .stream()
                .sorted(Comparator.comparingInt(PlaylistTrackEntity::getTrackOrder))
                .toList();

        List<GetPlaylistDetailResponse.TrackDetail> tracks = playlistTracks.stream()
                .map(playlistTrack -> {

                    TrackEntity track = trackClient.getTrackByTrackId(playlistTrack.getTrack().getTrackId());
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


}
