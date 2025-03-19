package com.ccc.ari.chart.domain.client;

import com.ccc.ari.chart.domain.Chart;

import java.util.Optional;

/**
 * 차트 레포지토리 인터페이스
 */
public interface ChartRepository {

    /**
     * 차트를 저장합니다.
     * 구현체에서는 MongoDB와 Redis에 모두 저장합니다.
     *
     * @param chart 저장할 차트
     */
    void save(Chart chart);

    /**
     * 최신 차트를 조회합니다.
     *
     * @return 조회된 차트
     */
    Optional<Chart> findLatest();
}
