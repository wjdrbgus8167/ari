package com.ccc.ari.chart.application.repository;

import com.ccc.ari.chart.domain.entity.Chart;

import java.util.Optional;

/**
 * 차트 엔티티를 저장하고 조회하기 위한 리포지토리 인터페이스
 */
public interface ChartRepository {

    // 차트 저장
    void save(Chart chart);

    // 최근 전체 차트 조회
    Optional<Chart> findLatestAllChart();

    // 최근 장르 차트 조회
    Optional<Chart> findLatestGenreChart(Integer genreId);
}
