package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularItemCacheRepository;
import com.ccc.ari.exhibition.domain.entity.NewAlbum;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class RedisNewAlbumCacheRepository implements PopularItemCacheRepository<NewAlbum> {

    private static final String NEW_ALBUM_ALL_KEY = "new:album:all";
    private static final String NEW_ALBUM_GENRE_KEY_PREFIX = "new:album:genre:";

    private final RedisTemplate<String, NewAlbum> redisTemplate;

    @Override
    public void cachePopularItem(Integer genreId, NewAlbum newAlbum) {
        if (genreId == null) {
            redisTemplate.opsForValue().set(NEW_ALBUM_ALL_KEY, newAlbum);
        } else {
            redisTemplate.opsForValue().set(NEW_ALBUM_GENRE_KEY_PREFIX + genreId, newAlbum);
        }
    }

    @Override
    public Optional<NewAlbum> getLatestPopularItem(Integer genreId) {
        NewAlbum newAlbum;
        if (genreId == null) {
            newAlbum = redisTemplate.opsForValue().get(NEW_ALBUM_ALL_KEY);
        } else {
            newAlbum = redisTemplate.opsForValue().get(NEW_ALBUM_GENRE_KEY_PREFIX + genreId);
        }
        return Optional.ofNullable(newAlbum);
    }
}
