package com.ccc.ari.chart.domain.client;

import com.ccc.ari.chart.domain.entity.Chart;

import java.util.Optional;

public interface ChartClient {

    // 최신 전체 차트 조회
    Optional<Chart> getLatestAllChart();

    // 최신 장르 차트 조회
    Optional<Chart> getLatestGenreChart(Integer genreId);
}
