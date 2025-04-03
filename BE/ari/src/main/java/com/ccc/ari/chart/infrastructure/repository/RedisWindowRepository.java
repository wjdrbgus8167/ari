package com.ccc.ari.chart.infrastructure.repository;

import com.ccc.ari.chart.domain.entity.StreamingWindow;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class RedisWindowRepository {

    private static final String ALL_WINDOW_KEY = "streaming:window:all";
    private static final String GENRE_WINDOW_KEY_PREFIX = "streaming:window:genre:";

    private final RedisTemplate<String, Map<String, StreamingWindow>> redisTemplate;

    // 전체 윈도우 저장
    public void saveAllTracksWindows(Map<Integer, StreamingWindow> windows) {
        Map<String, StreamingWindow> stringKeyMap = convertMapKeysToString(windows);
        redisTemplate.opsForValue().set(ALL_WINDOW_KEY, stringKeyMap);
    }

    // 장르별 윈도우 저장
    public void saveGenreTracksWindows(Integer genreId, Map<Integer, StreamingWindow> windows) {
        Map<String, StreamingWindow> stringKeyMap = convertMapKeysToString(windows);
        redisTemplate.opsForValue().set(GENRE_WINDOW_KEY_PREFIX + genreId, stringKeyMap);
    }

    // 전체 윈도우 조회
    public Map<Integer, StreamingWindow> getAllTracksWindows() {
        Map<String, StreamingWindow> stringKeyMap = redisTemplate.opsForValue().get(ALL_WINDOW_KEY);
        return convertMapKeysToInteger(stringKeyMap);
    }

    // 장르별 윈도우 조회
    public Map<Integer, StreamingWindow> getGenreTracksWindows(Integer genreId) {
        Map<String, StreamingWindow> stringKeyMap = redisTemplate.opsForValue().get(GENRE_WINDOW_KEY_PREFIX + genreId);
        return convertMapKeysToInteger(stringKeyMap);
    }

    private Map<String, StreamingWindow> convertMapKeysToString(Map<Integer, StreamingWindow> map) {
        Map<String, StreamingWindow> result = new HashMap<>();
        map.forEach((key, value) -> result.put(key.toString(), value));
        return result;
    }

    private Map<Integer, StreamingWindow> convertMapKeysToInteger(Map<String, StreamingWindow> map) {
        if (map == null) {
            return new HashMap<>();
        }

        Map<Integer, StreamingWindow> result = new HashMap<>();
        map.forEach((key, value) -> result.put(Integer.parseInt(key), value));
        return result;
    }
}
