package com.ccc.ari.chart.application.serviceImpl;

import com.ccc.ari.chart.application.dto.ChartResponseDto;
import com.ccc.ari.chart.application.ChartService;
import com.ccc.ari.chart.application.mapper.ChartMapper;
import com.ccc.ari.chart.domain.client.ChartRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * 차트 서비스 구현체
 */
@Service
@RequiredArgsConstructor
public class ChartServiceImpl implements ChartService {

    private final ChartRepository chartRepository;
    private final ChartMapper chartMapper;

    @Override
    public ChartResponseDto getLatestChart() {
        return chartRepository.findLatest()
                .map(chartMapper::toDto)
                .orElseThrow(() -> new RuntimeException("차트를 찾을 수 없습니다"));
    }
}
