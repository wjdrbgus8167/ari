package com.ccc.ari.exhibition.application.repository;

import java.util.Optional;

/**
 * 전시 아이템 캐싱 리포지토리 인터페이스
 */
public interface PopularMusicCacheRepository<T> {

    // 인기 음원 캐시 저장
    void cachePopularMusic(Integer genreId, T item);

    // 최신 인기 음원 조회
    Optional<T> getLatestPopularMusic(Integer genreId);
}
