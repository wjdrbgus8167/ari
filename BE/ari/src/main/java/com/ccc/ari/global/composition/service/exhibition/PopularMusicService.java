package com.ccc.ari.global.composition.service.exhibition;

import com.ccc.ari.exhibition.domain.client.PopularItemClient;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;
import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.ccc.ari.exhibition.domain.vo.TrackEntry;
import com.ccc.ari.global.composition.response.exhibition.PopularAlbumResponse;
import com.ccc.ari.global.composition.response.exhibition.PopularTrackResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PopularMusicService {

    private static final Logger logger = LoggerFactory.getLogger(PopularMusicService.class);

    private final PopularItemClient popularItemClient;
    private final AlbumClient albumClient;
    private final TrackClient trackClient;
    private final MemberClient memberClient;

    // 전체 인기 앨범 조회
    public PopularAlbumResponse getAllPopularAlbums() {
        return getPopularAlbums(null, ErrorCode.POPULAR_ALL_ALBUM_NOT_FOUND);
    }

    // 장르별 인기 앨범 조회
    public PopularAlbumResponse getGenrePopularAlbums(Integer genreId) {
        return getPopularAlbums(genreId, ErrorCode.POPULAR_GENRE_ALBUM_NOT_FOUND);
    }

    // 전체 인기 트랙 조회
    public PopularTrackResponse getAllPopularTracks() {
        return getPopularTracks(null, ErrorCode.POPULAR_ALL_TRACK_NOT_FOUND);
    }

    // 장르별 인기 트랙 조회
    public PopularTrackResponse getGenrePopularTracks(Integer genreId) {
        return getPopularTracks(genreId, ErrorCode.POPULAR_GENRE_TRACK_NOT_FOUND);
    }

    // 인기 앨범 조회 공통 로직
    private PopularAlbumResponse getPopularAlbums(Integer genreId, ErrorCode errorCode) {
        PopularAlbum popularAlbum = popularItemClient.getLatestPopularAlbum(genreId)
                .orElseThrow(() -> new ApiException(errorCode));

        List<PopularAlbumResponse.PopularAlbumItem> albumItems = new ArrayList<>();

        // 각 앨범의 상세 정보를 순차적으로 조회
        for (AlbumEntry entry : popularAlbum.getEntries()) {
            try {
                Integer albumId = entry.getAlbumId();
                PopularAlbumResponse.PopularAlbumItem item = buildAlbumItem(albumId);
                albumItems.add(item);
            } catch (Exception e) {
                logger.warn("앨범 ID {}에 대한 상세 정보를 조회할 수 없습니다: {}", entry.getAlbumId(), e.getMessage());
            }
        }

        return PopularAlbumResponse.builder().albums(albumItems).build();
    }

    // 앨범 아이템 생성 헬퍼 메서드
    private PopularAlbumResponse.PopularAlbumItem buildAlbumItem(Integer albumId) {
        AlbumDto albumDto = albumClient.getAlbumById(albumId);
        List<TrackDto> tracks = trackClient.getTracksByAlbumId(albumId);
        String artistName = memberClient.getNicknameByMemberId(albumDto.getMemberId());

        List<PopularAlbumResponse.TrackItem> trackItems = new ArrayList<>();
        for (TrackDto track : tracks) {
            trackItems.add(PopularAlbumResponse.TrackItem.builder()
                    .trackId(track.getTrackId())
                    .trackTitle(track.getTitle())
                    .trackFileUrl(track.getTrackFileUrl())
                    .build());
        }

        return PopularAlbumResponse.PopularAlbumItem.builder()
                .albumId(albumId)
                .albumTitle(albumDto.getTitle())
                .artist(artistName)
                .coverImageUrl(albumDto.getCoverImageUrl())
                .genreName(albumDto.getGenreName())
                .trackCount(tracks.size())
                .tracks(trackItems)
                .build();
    }

    // 인기 트랙 조회 공통 로직
    private PopularTrackResponse getPopularTracks(Integer genreId, ErrorCode errorCode) {
        PopularTrack popularTrack = popularItemClient.getLatestPopularTrack(genreId)
                .orElseThrow(() -> new ApiException(errorCode));

        List<PopularTrackResponse.PopularTrackItem> trackItems = new ArrayList<>();

        for (TrackEntry entry : popularTrack.getEntries()) {
            try {
                Integer trackId = entry.getTrackId();
                PopularTrackResponse.PopularTrackItem item = buildTrackItem(trackId);
                trackItems.add(item);
            } catch (Exception e) {
                logger.warn("트랙 ID {}에 대한 상세 정보를 조회할 수 없습니다: {}", entry.getTrackId(), e.getMessage());
            }
        }

        return PopularTrackResponse.builder().tracks(trackItems).build();
    }

    // 트랙 아이템 생성 헬퍼 메서드
    private PopularTrackResponse.PopularTrackItem buildTrackItem(Integer trackId) {
        TrackDto trackDto = trackClient.getTrackById(trackId);
        AlbumDto albumDto = albumClient.getAlbumById(trackDto.getAlbumId());
        String artistName = memberClient.getNicknameByMemberId(albumDto.getMemberId());

        return PopularTrackResponse.PopularTrackItem.builder()
                .trackId(trackId)
                .trackTitle(trackDto.getTitle())
                .artist(artistName)
                .coverImageUrl(albumDto.getCoverImageUrl())
                .trackFileUrl(trackDto.getTrackFileUrl())
                .build();
    }
}
