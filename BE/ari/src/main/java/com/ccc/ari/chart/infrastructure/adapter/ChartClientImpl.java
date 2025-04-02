package com.ccc.ari.chart.infrastructure.adapter;

import com.ccc.ari.chart.domain.client.ChartClient;
import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.infrastructure.repository.MongoChartRepository;
import com.ccc.ari.chart.infrastructure.repository.RedisChartCacheRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ChartClientImpl implements ChartClient {

    private final RedisChartCacheRepository redisChartCacheRepository;
    private final MongoChartRepository mongoChartRepository;

    @Override
    public Optional<Chart> getLatestAllChart() {
        Optional<Chart> cachedChart = redisChartCacheRepository.getLatestAllChart();

        if (cachedChart.isEmpty()) {
            Optional<Chart> persistedChart = mongoChartRepository.findLatestAllChart();

            if (persistedChart.isPresent()) {
                redisChartCacheRepository.cacheAllChart(persistedChart.get());
                return persistedChart;
            }
        }

        return cachedChart;
    }

    @Override
    public Optional<Chart> getLatestGenreChart(Integer genreId) {
        Optional<Chart> cachedChart = redisChartCacheRepository.getLatestGenreChart(genreId);

        if (cachedChart.isEmpty()) {
            Optional<Chart> persistedChart = mongoChartRepository.findLatestGenreChart(genreId);

            if (persistedChart.isPresent()) {
                redisChartCacheRepository.cacheGenreChart(genreId, persistedChart.get());
                return persistedChart;
            }
        }

        return cachedChart;
    }
}
