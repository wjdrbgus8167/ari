package com.ccc.ari.chart.application;

import com.ccc.ari.chart.application.dto.ChartResponseDto;

/**
 * 차트 조회 애플리케이션 서비스 인터페이스
 */
public interface ChartService {

    /**
     * 최신 차트를 조회합니다.
     *
     * @return 최신 차트
     */
    ChartResponseDto getLatestChart();
}
