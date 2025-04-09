package com.ccc.ari.exhibition.application.service;

import com.ccc.ari.exhibition.application.repository.PopularItemCacheRepository;
import com.ccc.ari.exhibition.application.repository.PopularItemRepository;
import com.ccc.ari.exhibition.application.repository.TrackStreamingWindowRepository;
import com.ccc.ari.exhibition.domain.entity.*;
import com.ccc.ari.exhibition.domain.service.PopularItemCreationService;
import com.ccc.ari.exhibition.domain.service.PopularStreamingWindowService;
import com.ccc.ari.exhibition.domain.vo.PlaylistEntry;
import com.ccc.ari.global.event.AllAggregationCalculatedEvent;
import com.ccc.ari.global.event.GenreAggregationCalculatedEvent;
import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.client.GenreClient;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PopularItemUpdateService {

    private static final Logger logger = LoggerFactory.getLogger(PopularItemUpdateService.class);
    private final GenreClient genreClient;
    private final PlaylistClient playlistClient;
    private final PopularStreamingWindowService windowService;
    private final PopularItemCreationService popularItemCreationService;
    private final TrackStreamingWindowRepository windowRepository;
    private final PopularItemRepository<PopularTrack> trackRepository;
    private final PopularItemRepository<PopularAlbum> albumRepository;
    private final PopularItemCacheRepository<PopularTrack> trackCacheRepository;
    private final PopularItemCacheRepository<PopularAlbum> albumCacheRepository;
    private final PopularItemRepository<PopularPlaylist> playlistRepository;
    private final PopularItemCacheRepository<PopularPlaylist> playlistCacheRepository;
    private final PopularItemRepository<NewAlbum> newAlbumRepository;
    private final PopularItemCacheRepository<NewAlbum> newAlbumCacheRepository;

    @EventListener
    public void handleAllAggregationEvent(AllAggregationCalculatedEvent event) {
        logger.info("전체 인기 음원 갱신을 위한 이벤트를 수신했습니다.");
        Map<Integer, Long> trackCounts = event.getTrackCounts();

        Map<Integer, TrackStreamingWindow> allTracksWindows = windowRepository.getAllTracksWindows();
        allTracksWindows = windowService.updateStreamingWindows(allTracksWindows, trackCounts, Instant.now());
        windowRepository.saveAllTracksWindows(allTracksWindows);

        logger.info("전체 인기 음원이 성공적으로 갱신되었습니다. 트랙 수: {}", allTracksWindows.size());
    }

    @EventListener
    public void handleGenreAggregationEvent(GenreAggregationCalculatedEvent event) {
        logger.info("장르별 인기 음원 갱신을 위한 이벤트를 수신했습니다.");
        Map<Integer, Map<Integer, Long>> genreTrackCounts = event.getGenreTrackCounts();

        for (Map.Entry<Integer, Map<Integer, Long>> entry : genreTrackCounts.entrySet()) {
            Integer genreId = entry.getKey();
            Map<Integer, Long> trackCounts = entry.getValue();

            Map<Integer, TrackStreamingWindow> genreWindows = windowRepository.getGenreTracksWindows(genreId);
            genreWindows = windowService.updateStreamingWindows(genreWindows, trackCounts, Instant.now());
            windowRepository.saveGenreTracksWindows(genreId, genreWindows);

            logger.info("장르 ID {}의 인기 음원이 성공적으로 갱신되었습니다. 트랙 수: {}", genreId, genreWindows.size());
        }
    }

    /**
     * 매일 오전 6시 30초 인기 트랙 및 앨범을 계산하고 저장합니다.
     */
    @Scheduled(cron = "0 15 4/3 * * *")
    public void updatePopularMusic() {
        logger.info("인기 트랙 및 앨범 업데이트를 시작합니다.");

        // 전체 인기 트랙 및 앨범 업데이트
        updateAllPopularMusic();

        // 인기 플레이리스트 업데이트
        updatePopularPlaylist();

        // 전체 최신 앨범 업데이트
        updateAllNewAlbum();

        Map<Integer, TrackStreamingWindow> allWindows = windowRepository.getAllTracksWindows();
        if (allWindows == null || allWindows.isEmpty()) {
            logger.info("스트리밍 데이터가 없으므로 인기 음원 갱신을 건너뜁니다.");
            return;
        }

        // 장르별 인기 트랙 및 앨범 업데이트
        List<Integer> genreIds = getAllGenreIds();
        for (Integer genreId : genreIds) {
            Map<Integer, TrackStreamingWindow> genreWindows = windowRepository.getGenreTracksWindows(genreId);
            if (genreWindows == null || genreWindows.isEmpty()) {
                logger.info("장르 ID {}의 스트리밍 데이터가 없습니다. 인기 음악 업데이트를 건너뜁니다.", genreId);
                continue;
            }

            updateGenrePopularMusic(genreId);
        }

        // 장르별 최신 앨범 업데이트
        updateGenreNewAlbum();

        logger.info("인기 트랙 및 앨범 업데이트가 완료되었습니다.");
    }

    private List<Integer> getAllGenreIds() {
        List<GenreDto> allGenres = genreClient.getAllGenres();
        return allGenres.stream()
                .map(GenreDto::getGenreId)
                .toList();
    }

    private void updateAllPopularMusic() {
        // 전체 트랙 스트리밍 윈도우 조회
        Map<Integer, TrackStreamingWindow> allWindows = windowRepository.getAllTracksWindows();

        // 인기 트랙 생성 및 저장
        PopularTrack popularTrack = popularItemCreationService.createPopularTrack(null, allWindows);
        trackRepository.save(popularTrack);
        trackCacheRepository.cachePopularItem(null, popularTrack);

        // 인기 앨범 생성 및 저장
        PopularAlbum popularAlbum = popularItemCreationService.createPopularAlbum(null, allWindows);
        albumRepository.save(popularAlbum);
        albumCacheRepository.cachePopularItem(null, popularAlbum);

        logger.info("전체 인기 트랙 및 앨범이 성공적으로 업데이트되었습니다. 트랙: {}, 앨범: {}",
                popularTrack.getEntries().size(), popularAlbum.getEntries().size());
    }

    private void updateGenrePopularMusic(Integer genreId) {
        // 장르별 트랙 스트리밍 윈도우 조회
        Map<Integer, TrackStreamingWindow> genreWindows = windowRepository.getGenreTracksWindows(genreId);

        // 인기 트랙 생성 및 저장
        PopularTrack popularTrack = popularItemCreationService.createPopularTrack(genreId, genreWindows);
        trackRepository.save(popularTrack);
        trackCacheRepository.cachePopularItem(genreId, popularTrack);

        // 인기 앨범 생성 및 저장
        PopularAlbum popularAlbum = popularItemCreationService.createPopularAlbum(genreId, genreWindows);
        albumRepository.save(popularAlbum);
        albumCacheRepository.cachePopularItem(genreId, popularAlbum);

        logger.info("장르 ID {}의 인기 트랙 및 앨범이 성공적으로 업데이트되었습니다. 트랙: {}, 앨범: {}",
                genreId, popularTrack.getEntries().size(), popularAlbum.getEntries().size());
    }

    private void updatePopularPlaylist() {
        List< PlaylistEntity> topPlaylists = playlistClient.getTop5MostSharedPlaylists();

        // PlaylistEntry 목록 생성
        List<PlaylistEntry> entries = topPlaylists.stream()
                .map(playlist -> PlaylistEntry.builder()
                        .playlistId(playlist.getPlaylistId())
                        .shareCount(playlist.getShareCount())
                        .build())
                .toList();

        // 인기 플레이리스트 엔티티 생성
        PopularPlaylist popularPlaylist = PopularPlaylist.builder()
                .entries(entries)
                .createdAt(LocalDateTime.now())
                .build();

        // 저장 및 캐싱
        playlistRepository.save(popularPlaylist);
        playlistCacheRepository.cachePopularItem(null, popularPlaylist);

        logger.info("인기 플레이리스트가 성공적으로 업데이트되었습니다. 플레이리스트: {}", entries.size());
    }

    private void updateAllNewAlbum() {
        NewAlbum newAlbum = popularItemCreationService.createNewAlbum(null);

        newAlbumRepository.save(newAlbum);
        newAlbumCacheRepository.cachePopularItem(null, newAlbum);

        logger.info("전체 최신 앨범이 성공적으로 업데이트되었습니다. 앨범 수: {}", newAlbum.getEntries().size());
    }

    private void updateGenreNewAlbum() {
        List<Integer> genreIds = getAllGenreIds();

        for (Integer genreId : genreIds) {
            NewAlbum newAlbum = popularItemCreationService.createNewAlbum(genreId);

            if (newAlbum.getEntries().isEmpty()) {
                logger.info("장르 ID {}의 최신 앨범이 없습니다. 업데이트를 건너뜁니다.", genreId);
                continue;
            }

            newAlbumRepository.save(newAlbum);
            newAlbumCacheRepository.cachePopularItem(genreId, newAlbum);

            logger.info("장르 ID {}의 최신 앨범이 성공적으로 업데이트되었습니다. 앨범 수: {}",
                    genreId, newAlbum.getEntries().size());
        }
    }
}
