package com.ccc.ari.exhibition.application.repository;

import java.util.Optional;

/**
 * 전시 아이템 캐싱 리포지토리 인터페이스
 */
public interface PopularItemCacheRepository<T> {

    void cachePopularItem(Integer genreId, T item);

    Optional<T> getLatestPopularItem(Integer genreId);
}
