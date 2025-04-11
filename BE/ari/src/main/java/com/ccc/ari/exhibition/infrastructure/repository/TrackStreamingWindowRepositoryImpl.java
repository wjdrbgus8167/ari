package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.TrackStreamingWindowRepository;
import com.ccc.ari.exhibition.domain.entity.TrackStreamingWindow;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class TrackStreamingWindowRepositoryImpl implements TrackStreamingWindowRepository {

    private static final String ALL_WINDOW_KEY = "exhibition:window:all";
    private static final String GENRE_WINDOW_KEY_PREFIX = "exhibition:window:genre:";

    private final RedisTemplate<String, Map<String, TrackStreamingWindow>> redisTemplate;

    @Override
    public void saveAllTracksWindows(Map<Integer, TrackStreamingWindow> windows) {
        Map<String, TrackStreamingWindow> stringKeyMap = convertKeysToString(windows);
        redisTemplate.opsForValue().set(ALL_WINDOW_KEY, stringKeyMap);
    }

    // 장르별 윈도우 저장
    @Override
    public void saveGenreTracksWindows(Integer genreId, Map<Integer, TrackStreamingWindow> windows) {
        Map<String, TrackStreamingWindow> stringKeyMap = convertKeysToString(windows);
        redisTemplate.opsForValue().set(GENRE_WINDOW_KEY_PREFIX + genreId, stringKeyMap);
    }

    // 전체 윈도우 조회
    @Override
    public Map<Integer, TrackStreamingWindow> getAllTracksWindows() {
        Map<String, TrackStreamingWindow> stringKeyMap = redisTemplate.opsForValue().get(ALL_WINDOW_KEY);
        return convertKeysToInteger(stringKeyMap);
    }

    // 장르별 윈도우 조회
    @Override
    public Map<Integer, TrackStreamingWindow> getGenreTracksWindows(Integer genreId) {
        Map<String, TrackStreamingWindow> stringKeyMap = redisTemplate.opsForValue()
                .get(GENRE_WINDOW_KEY_PREFIX + genreId);
        return convertKeysToInteger(stringKeyMap);
    }

    private Map<String, TrackStreamingWindow> convertKeysToString(Map<Integer, TrackStreamingWindow> map) {
        Map<String, TrackStreamingWindow> result = new HashMap<>();
        map.forEach((key, value) -> result.put(key.toString(), value));
        return result;
    }

    private Map<Integer, TrackStreamingWindow> convertKeysToInteger(Map<String, TrackStreamingWindow> map) {
        if (map == null) {
            return new HashMap<>();
        }

        Map<Integer, TrackStreamingWindow> result = new HashMap<>();
        map.forEach((key, value) -> result.put(Integer.parseInt(key), value));
        return result;
    }
}
