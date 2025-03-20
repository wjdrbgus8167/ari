package com.ccc.ari.chart.infrastructure;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class RedisChartCache {

    private static final Logger logger = LoggerFactory.getLogger(RedisChartCache.class);
    private static final String LATEST_CHART_KEY = "chart:latest";

    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    /**
     * 차트 데이터를 Redis에 캐싱합니다.
     */
    public void cacheChart(ChartDocument document) {
        try {
            String json = objectMapper.writeValueAsString(document);
            redisTemplate.opsForValue().set(LATEST_CHART_KEY, json);
            logger.info("최신 차트가 Redis에 저장되었숩나다.");
        } catch (Exception e) {
            logger.error("Redis 캐싱 실패", e);
        }
    }

    /**
     * 최신 차트 데이터를 조회합니다.
     */
    public Optional<ChartDocument> getLatestChart() {
        try {
            String json = redisTemplate.opsForValue().get(LATEST_CHART_KEY);
            if (json == null) {
                return Optional.empty();
            }

            ChartDocument document = objectMapper.readValue(json, ChartDocument.class);
            logger.info("Redis 캐시에서 최신 차트를 찾았습니다.");
            return Optional.of(document);
        } catch (Exception e) {
            logger.error("Redis 캐시 조회 실패", e);
            return Optional.empty();
        }
    }
}
