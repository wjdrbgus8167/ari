package com.ccc.ari.exhibition.application.service;

import com.ccc.ari.exhibition.application.repository.PopularMusicCacheRepository;
import com.ccc.ari.exhibition.application.repository.PopularMusicRepository;
import com.ccc.ari.exhibition.application.repository.TrackStreamingWindowRepository;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;
import com.ccc.ari.exhibition.domain.entity.TrackStreamingWindow;
import com.ccc.ari.exhibition.domain.service.PopularMusicCreationService;
import com.ccc.ari.exhibition.domain.service.PopularStreamingWindowService;
import com.ccc.ari.global.event.AllAggregationCalculatedEvent;
import com.ccc.ari.global.event.GenreAggregationCalculatedEvent;
import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.client.GenreClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PopularMusicUpdateService {

    private static final Logger logger = LoggerFactory.getLogger(PopularMusicUpdateService.class);
    private final TrackStreamingWindowRepository windowRepository;
    private final PopularStreamingWindowService windowService;
    private final GenreClient genreClient;
    private final PopularMusicCreationService popularMusicCreationService;
    private final PopularMusicRepository<PopularTrack> trackRepository;
    private final PopularMusicRepository<PopularAlbum> albumRepository;
    private final PopularMusicCacheRepository<PopularTrack> trackCacheRepository;
    private final PopularMusicCacheRepository<PopularAlbum> albumCacheRepository;

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
     * 매일 오전 6시 인기 트랙 및 앨범을 계산하고 저장합니다.
     */
    @Scheduled(cron = "30 */1 * * * *")
    public void updatePopularMusic() {
        logger.info("인기 트랙 및 앨범 업데이트를 시작합니다.");


        // 전체 인기 트랙 및 앨범 업데이트
        updateAllPopularMusic();

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
        PopularTrack popularTrack = popularMusicCreationService.createPopularTrack(null, allWindows);
        trackRepository.save(popularTrack);
        trackCacheRepository.cachePopularMusic(null, popularTrack);

        // 인기 앨범 생성 및 저장
        PopularAlbum popularAlbum = popularMusicCreationService.createPopularAlbum(null, allWindows);
        albumRepository.save(popularAlbum);
        albumCacheRepository.cachePopularMusic(null, popularAlbum);

        logger.info("전체 인기 트랙 및 앨범이 성공적으로 업데이트되었습니다. 트랙: {}, 앨범: {}",
                popularTrack.getEntries().size(), popularAlbum.getEntries().size());
    }

    private void updateGenrePopularMusic(Integer genreId) {
        // 장르별 트랙 스트리밍 윈도우 조회
        Map<Integer, TrackStreamingWindow> genreWindows = windowRepository.getGenreTracksWindows(genreId);

        // 인기 트랙 생성 및 저장
        PopularTrack popularTrack = popularMusicCreationService.createPopularTrack(genreId, genreWindows);
        trackRepository.save(popularTrack);
        trackCacheRepository.cachePopularMusic(genreId, popularTrack);

        // 인기 앨범 생성 및 저장
        PopularAlbum popularAlbum = popularMusicCreationService.createPopularAlbum(genreId, genreWindows);
        albumRepository.save(popularAlbum);
        albumCacheRepository.cachePopularMusic(genreId, popularAlbum);

        logger.info("장르 ID {}의 인기 트랙 및 앨범이 성공적으로 업데이트되었습니다. 트랙: {}, 앨범: {}",
                genreId, popularTrack.getEntries().size(), popularAlbum.getEntries().size());
    }
}
