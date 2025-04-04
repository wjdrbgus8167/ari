package com.ccc.ari.exhibition.infrastructure.repository;

import com.ccc.ari.exhibition.application.repository.PopularItemCacheRepository;
import com.ccc.ari.exhibition.domain.entity.PopularPlaylist;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class RedisPopularPlaylistCacheRepository implements PopularItemCacheRepository<PopularPlaylist> {

    private static final String PLAYLIST_KEY = "popular:playlist";
    private final RedisTemplate<String, PopularPlaylist> redisTemplate;

    @Override
    public void cachePopularItem(Integer genreId, PopularPlaylist playlist) {
        redisTemplate.opsForValue().set(PLAYLIST_KEY, playlist);
    }

    @Override
    public Optional<PopularPlaylist> getLatestPopularItem(Integer genreId) {
        PopularPlaylist playlist = redisTemplate.opsForValue().get(PLAYLIST_KEY);
        return Optional.ofNullable(playlist);
    }
}
