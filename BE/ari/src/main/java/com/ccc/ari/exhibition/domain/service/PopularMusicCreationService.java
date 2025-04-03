package com.ccc.ari.exhibition.domain.service;

import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;
import com.ccc.ari.exhibition.domain.entity.TrackStreamingWindow;
import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
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
public class PopularMusicCreationService {

    private static final Logger logger = LoggerFactory.getLogger(PopularMusicCreationService.class);
    private final PopularStreamingWindowService popularStreamingWindowService;
    private final PopularMusicSelectionService selectionService;

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

        logger.info("인기 트랙 생성 완료: 항목 수={}", entries.size());
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

        logger.info("인기 앨범 생성 완료: 항목 수={}", entries.size());
        return popularAlbum;
    }
}
