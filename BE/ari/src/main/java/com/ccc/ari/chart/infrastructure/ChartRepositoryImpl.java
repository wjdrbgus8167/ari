package com.ccc.ari.chart.infrastructure;

import com.ccc.ari.chart.domain.Chart;
import com.ccc.ari.chart.domain.client.ChartRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ChartRepositoryImpl implements ChartRepository {

    private static final Logger logger = LoggerFactory.getLogger(ChartRepositoryImpl.class);
    private final MongoChartRepository mongoRepository;
    private final RedisChartCache redisCache;
    private final ChartDocumentMapper mapper;

    /**
     * 차트 데이터를 저장합니다.
     *
     * @param chart 저장할 차트
     */
    @Override
    public void save(Chart chart) {
        logger.info("차트 저장 시작");

        ChartDocument document = mapper.toDocument(chart);

        ChartDocument savedDocument = mongoRepository.save(document);
        logger.info("차트가 MongoDB에 저장되었습니다. ID: {}", savedDocument.getId());

        redisCache.cacheChart(savedDocument);
    }

    /**
     * 최신 차트를 조회합니다.
     *
     * @return 최신 차트
     */
    @Override
    public Optional<Chart> findLatest() {
        logger.info("최신 차트 조회 시작");

        // 1. 먼저 Redis 캐시에서 조회
        Optional<ChartDocument> cachedDocument = redisCache.getLatestChart();

        // 2. 캐시에 없으면 MongoDB에서 조회
        Optional<ChartDocument> document = cachedDocument.isPresent() ? cachedDocument : mongoRepository.findTopByOrderByCreatedAtDesc();

        // 3. MongoDB 데이터를 도메인 모델로 변환
        return document.map(mapper::toDomain);
    }
}
