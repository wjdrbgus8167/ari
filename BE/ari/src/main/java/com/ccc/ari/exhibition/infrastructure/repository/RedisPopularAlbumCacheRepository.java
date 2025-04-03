package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularMusicCacheRepository;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class RedisPopularAlbumCacheRepository implements PopularMusicCacheRepository<PopularAlbum> {

    private static final String ALL_KEY = "popular:album:all";
    private static final String GENRE_KEY_PREFIX = "popular:album:genre:";

    private final RedisTemplate<String, PopularAlbum> redisTemplate;

    @Override
    public void cachePopularMusic(Integer genreId, PopularAlbum item) {
        if (genreId == null) {
            redisTemplate.opsForValue().set(ALL_KEY, item);
        } else {
            redisTemplate.opsForValue().set(GENRE_KEY_PREFIX + genreId, item);
        }
    }

    @Override
    public Optional<PopularAlbum> getLatestPopularMusic(Integer genreId) {
        PopularAlbum album;
        if (genreId == null) {
            album = redisTemplate.opsForValue().get(ALL_KEY);
        } else {
            album = redisTemplate.opsForValue().get(GENRE_KEY_PREFIX + genreId);
        }
        return Optional.ofNullable(album);
    }
}
