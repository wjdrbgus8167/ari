package com.ccc.ari.exhibition.application.repository;

import java.util.Optional;

/**
 * 전시 아이템을 저장하고 조회하기 위한 리포지토리 인터페이스
 */
public interface PopularMusicRepository<T> {

    // 인기 음원 저장
    void save(T item);

    // 최신 인기 음원 조회
    Optional<T> findLatestPopularMusic(Integer genreId);
}
