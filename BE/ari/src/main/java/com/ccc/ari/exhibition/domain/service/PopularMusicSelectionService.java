package com.ccc.ari.exhibition.domain.service;

import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.ccc.ari.exhibition.domain.vo.TrackEntry;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 인기 앨범 및 트랙을 계산하는 도메인 서비스
 */
@Service
@RequiredArgsConstructor
public class PopularMusicSelectionService {

    private static final Logger logger = LoggerFactory.getLogger(PopularMusicSelectionService.class);
    private static final int MAX_POPULAR_ITEMS = 20;

    private final TrackClient trackClient;

    /**
     * 인기 트랙 20개를 선택합니다.
     *
     * @param streamCounts 스트리밍 데이터
     * @return 인기 트랙 엔트리
     */
    public List<TrackEntry> selectPopularTracks(Map<Integer, Long> streamCounts) {
        // 스트리밍 횟수를 기준으로 내림차순 정렬하여 상위 20개 선택
        List<Map.Entry<Integer, Long>> sortedEntries = streamCounts.entrySet().stream()
                .sorted(Map.Entry.<Integer, Long>comparingByValue().reversed())
                .limit(MAX_POPULAR_ITEMS)
                .toList();

        // TrackEntry 목록 생성
        List<TrackEntry> entries = new ArrayList<>();

        for (int i = 0; i < sortedEntries.size(); i++) {
            Map.Entry<Integer, Long> entry = sortedEntries.get(i);
            Integer trackId = entry.getKey();
            Long count = entry.getValue();

            entries.add(TrackEntry.builder()
                    .trackId(trackId)
                    .streamCount(count)
                    .build());
        }

        logger.info("인기 트랙 {}개를 선택했습니다.", entries.size());
        return entries;
    }

    /**
     * 인기 앨범 20개를 선택합니다.
     *
     * @param streamCounts 스트리밍 데이터
     * @return 인기 앨범 엔트리
     */
    public List<AlbumEntry> selectPopularAlbums(Map<Integer, Long> streamCounts) {
        // 트랙 스트리밍 데이터로부터 앨범 데이터 집계
        Map<Integer, Long> albumStreamCounts = new HashMap<>();

        // 트랙별 앨범 정보 조회 및 집계
        for (Map.Entry<Integer, Long> entry : streamCounts.entrySet()) {
            Integer trackId = entry.getKey();
            Long streamCount = entry.getValue();

            try {
                TrackDto track = trackClient.getTrackById(trackId);
                Integer albumId = track.getAlbumId();

                // 앨범별 스트리밍 집계
                albumStreamCounts.merge(albumId, streamCount, Long::sum);
            } catch (Exception e) {
                logger.warn("트랙 ID {}의 앨범 정보를 조회할 수 없습니다: {}", trackId, e.getMessage());
            }
        }

        // 스트리밍 횟수를 기준으로 내림차순 정렬하여 상위 20개 선택
        List<Map.Entry<Integer, Long>> sortedEntries = albumStreamCounts.entrySet().stream()
                .sorted(Map.Entry.<Integer, Long>comparingByValue().reversed())
                .limit(MAX_POPULAR_ITEMS)
                .toList();

        // AlbumRankEntry 목록 생성
        List<AlbumEntry> entries = new ArrayList<>();

        for (int i = 0; i < sortedEntries.size(); i++) {
            Map.Entry<Integer, Long> entry = sortedEntries.get(i);
            Integer albumId = entry.getKey();
            Long count = entry.getValue();

            entries.add(AlbumEntry.builder()
                    .albumId(albumId)
                    .streamCount(count)
                    .build());
        }

        logger.info("인기 앨범 {}개를 선택했습니다.", entries.size());
        return entries;
    }
}
