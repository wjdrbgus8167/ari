package com.ccc.ari.global.composition.service.exhibition;

import com.ccc.ari.exhibition.domain.client.PopularItemClient;
import com.ccc.ari.exhibition.domain.entity.PopularPlaylist;
import com.ccc.ari.exhibition.domain.vo.PlaylistEntry;
import com.ccc.ari.global.composition.response.exhibition.PopularPlaylistResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import com.ccc.ari.playlist.domain.playlisttrack.client.PlaylistTrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PopularPlaylistService {

    private final PopularItemClient popularItemClient;
    private final PlaylistClient playlistClient;
    private final MemberClient memberClient;
    private final PlaylistTrackClient playlistTrackClient;
    private final TrackClient trackClient;
    private final AlbumClient albumClient;

    public PopularPlaylistResponse getPopularPlaylists() {
        // 인기 플레이리스트 조회
        PopularPlaylist popularPlaylist = popularItemClient.getLatestPopularPlaylist()
                .orElseThrow(() -> new ApiException(ErrorCode.POPULAR_PLAYLIST_NOT_FOUND));

        List<PopularPlaylistResponse.PopularPlaylistItem> playlistItems = new ArrayList<>();

        // 각 플레이리스트 항목 처리
        for (PlaylistEntry entry : popularPlaylist.getEntries()) {
            Integer playlistId = entry.getPlaylistId();

            Playlist playlist = playlistClient.getPlaylistById(playlistId);
            String memberName = memberClient.getNicknameByMemberId(playlist.getMemberId());
            Integer trackCount = playlistTrackClient.getTrackCount(playlistId);
            List<PlaylistTrackEntity> playlistTracks = playlistTrackClient.getPlaylistTracks(playlistId);

            // 트랙 목록 구성
            List<PopularPlaylistResponse.TrackItem> trackItems = new ArrayList<>();
            String coverImageUrl = null;

            for (PlaylistTrackEntity playlistTrack : playlistTracks) {
                TrackEntity trackEntity = playlistTrack.getTrack();
                Integer trackId = trackEntity.getTrackId();

                TrackDto trackDto = trackClient.getTrackById(trackId);
                AlbumDto albumDto = albumClient.getAlbumById(trackDto.getAlbumId());
                String artistName = memberClient.getNicknameByMemberId(albumDto.getMemberId());

                // 첫 번째 트랙의 커버 이미지를 플레이리스트 커버로 사용
                if (coverImageUrl == null) {
                    coverImageUrl = albumDto.getCoverImageUrl();
                }

                trackItems.add(PopularPlaylistResponse.TrackItem.builder()
                        .trackId(trackId)
                        .albumId(trackDto.getAlbumId())
                        .trackTitle(trackDto.getTitle())
                        .trackCoverImageUrl(albumDto.getCoverImageUrl())
                        .artistName(artistName)
                        .trackFileUrl(trackDto.getTrackFileUrl())
                        .build());
            }

            playlistItems.add(PopularPlaylistResponse.PopularPlaylistItem.builder()
                    .playlistId(playlistId)
                    .memberName(memberName)
                    .playlistTitle(playlist.getPlayListTitle())
                    .coverImageUrl(coverImageUrl)
                    .trackCount(trackCount)
                    .tracks(trackItems)
                    .build());
        }

        return PopularPlaylistResponse.builder()
                .playlists(playlistItems)
                .build();
    }
}
