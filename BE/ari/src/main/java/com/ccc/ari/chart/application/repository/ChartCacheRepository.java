package com.ccc.ari.chart.application.repository;

import com.ccc.ari.chart.domain.entity.Chart;

import java.util.Optional;

/**
 * 차트를 캐싱하고 빠르게 조회하기 위한 캐시 리포지토리 인터페이스
 */
public interface ChartCacheRepository {

    // 전체 차트 캐시 저장
    void cacheAllChart(Chart chart);

    // 장르 차트 캐시 저장
    void cacheGenreChart(Integer genreId, Chart chart);

    // 최신 전체 차트 조회
    Optional<Chart> getLatestAllChart();

    // 최신 장르 차트 조회
    Optional<Chart> getLatestGenreChart(Integer genreId);
}
