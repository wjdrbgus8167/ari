package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularItemCacheRepository;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class RedisPopularTrackCacheRepository implements PopularItemCacheRepository<PopularTrack> {

    private static final String ALL_KEY = "popular:track:all";
    private static final String GENRE_KEY_PREFIX = "popular:track:genre:";

    private final RedisTemplate<String, PopularTrack> redisTemplate;

    @Override
    public void cachePopularItem(Integer genreId, PopularTrack item) {
        if (genreId == null) {
            redisTemplate.opsForValue().set(ALL_KEY, item);
        } else {
            redisTemplate.opsForValue().set(GENRE_KEY_PREFIX + genreId, item);
        }
    }

    @Override
    public Optional<PopularTrack> getLatestPopularItem(Integer genreId) {
        PopularTrack track;
        if (genreId == null) {
            track = redisTemplate.opsForValue().get(ALL_KEY);
        } else {
            track = redisTemplate.opsForValue().get(GENRE_KEY_PREFIX + genreId);
        }
        return Optional.ofNullable(track);
    }
}
