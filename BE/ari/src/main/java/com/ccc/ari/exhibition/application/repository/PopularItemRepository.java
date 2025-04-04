package com.ccc.ari.exhibition.application.repository;

import java.util.Optional;

/**
 * 전시 아이템을 저장하고 조회하기 위한 리포지토리 인터페이스
 */
public interface PopularItemRepository<T> {

    void save(T item);

    Optional<T> findLatestPopularItem(Integer genreId);
}
