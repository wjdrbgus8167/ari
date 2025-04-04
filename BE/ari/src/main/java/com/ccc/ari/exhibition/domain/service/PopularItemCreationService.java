package com.ccc.ari.exhibition.domain.service;

import com.ccc.ari.exhibition.domain.entity.*;
import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.ccc.ari.exhibition.domain.vo.PlaylistEntry;
import com.ccc.ari.exhibition.domain.vo.TrackEntry;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 인기 앨범 및 트랙을 생성하는 도메인 서비스
 */
@Service
@RequiredArgsConstructor
public class PopularItemCreationService {

    private static final Logger logger = LoggerFactory.getLogger(PopularItemCreationService.class);
    private final PopularStreamingWindowService popularStreamingWindowService;
    private final PopularItemSelectionService selectionService;

    // 인기 트랙 생성
    public PopularTrack createPopularTrack(Integer genreId, Map<Integer, TrackStreamingWindow> streamingWindows) {
        // 각 트랙의 총 스트리밍 횟수 계산
        Map<Integer, Long> totalStreamCounts = popularStreamingWindowService.calculateAllStreamCounts(streamingWindows);

        // 인기 트랙 순위 계산
        List<TrackEntry> entries = selectionService.selectPopularTracks(totalStreamCounts);

        // 인기 트랙 객체 생성
        PopularTrack popularTrack = PopularTrack.builder()
                .genreId(genreId)
                .entries(entries)
                .createdAt(LocalDateTime.now())
                .build();

        logger.info("장르 {} 인기 트랙을 생성했습니다. 항목 수: {}", genreId, entries.size());
        return popularTrack;
    }

    // 인기 앨범 생성
    public PopularAlbum createPopularAlbum(Integer genreId, Map<Integer, TrackStreamingWindow> streamingWindows) {
        // 각 트랙의 총 스트리밍 횟수 계산
        Map<Integer, Long> totalStreamCounts = popularStreamingWindowService.calculateAllStreamCounts(streamingWindows);

        // 인기 앨범 순위 계산
        List<AlbumEntry> entries = selectionService.selectPopularAlbums(totalStreamCounts);

        // 인기 앨범 객체 생성
        PopularAlbum popularAlbum = PopularAlbum.builder()
                .genreId(genreId)
                .entries(entries)
                .createdAt(LocalDateTime.now())
                .build();

        logger.info("장르 {} 인기 앨범을 생성했습니다. 항목 수: {}", genreId, entries.size());
        return popularAlbum;
    }

    // 인기 플레이리스트 생성
    public PopularPlaylist createPopularPlaylist() {
        // 인기 플레이리스트 순위 계산
        List<PlaylistEntry> entries = selectionService.selectPopularPlaylists();

        // 인기 플레이리스트 객체 생성
        PopularPlaylist popularPlaylist = PopularPlaylist.builder()
                .entries(entries)
                .createdAt(LocalDateTime.now())
                .build();

        logger.info("인기 플레이리스트를 생성했습니다. 항목 수: {}", entries.size());
        return popularPlaylist;
    }

    // 최신 앨범 생성
    public NewAlbum createNewAlbum(Integer genreId) {
        List<AlbumEntry> entries = selectionService.selectNewAlbums(genreId);

        NewAlbum newAlbum = NewAlbum.builder()
                .genreId(genreId)
                .entries(entries)
                .createdAt(LocalDateTime.now())
                .build();

        logger.info("장르 {} 최신 앨범을 생성했습니다. 항목 수: {}", genreId, entries.size());
        return newAlbum;
    }
}
