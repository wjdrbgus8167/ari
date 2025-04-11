package com.ccc.ari.chart.infrastructure.repository;

import com.ccc.ari.chart.application.repository.ChartCacheRepository;
import com.ccc.ari.chart.domain.entity.Chart;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Redis를 사용한 차트 캐시 리포지토리 구현체
 */
@Repository
@RequiredArgsConstructor
public class RedisChartCacheRepository implements ChartCacheRepository {

    private static final String ALL_CHART_KEY_PREFIX = "chart:all";
    private static final String GENRE_CHART_KEY_PREFIX = "chart:genre:";
    private final RedisTemplate<String, Chart> redisTemplate;

    @Override
    public void cacheAllChart(Chart chart) {
        redisTemplate.opsForValue().set(ALL_CHART_KEY_PREFIX, chart);
    }

    @Override
    public void cacheGenreChart(Integer genreId, Chart chart) {
        String key = GENRE_CHART_KEY_PREFIX + genreId;
        redisTemplate.opsForValue().set(key, chart);
    }

    @Override
    public Optional<Chart> getLatestAllChart() {
        Chart chart = redisTemplate.opsForValue().get(ALL_CHART_KEY_PREFIX);
        return Optional.ofNullable(chart);
    }

    @Override
    public Optional<Chart> getLatestGenreChart(Integer genreId) {
        String key = GENRE_CHART_KEY_PREFIX + genreId;
        Chart chart = redisTemplate.opsForValue().get(key);
        return Optional.ofNullable(chart);
    }
}

