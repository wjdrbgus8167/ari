package com.ccc.ari.chart.infrastructure.repository;

import com.ccc.ari.chart.application.repository.ChartRepository;
import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.infrastructure.entity.MongoChart;
import com.ccc.ari.chart.infrastructure.mapper.ChartMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * MongoDB를 사용한 차트 리포지토리 구현체
 */
@Repository
@RequiredArgsConstructor
public class MongoChartRepository implements ChartRepository {

    private final ChartMapper chartMapper;
    private final MongoTemplate mongoTemplate;

    @Override
    public void save(Chart chart) {
        // 도메인 엔티티를 MongoDB 문서로 변환
        MongoChart mongoChart = chartMapper.toMongoEntity(chart);

        // MongoDB에 저장
        mongoTemplate.save(mongoChart, "charts");
    }

    @Override
    public Optional<Chart> findLatestAllChart() {
        Query query = Query.query(Criteria.where("genreId").is(null))
                .with(Sort.by(Sort.Direction.DESC, "createdAt"))
                .limit(1);

        MongoChart mongoChart = mongoTemplate.findOne(query, MongoChart.class, "charts");

        return Optional.ofNullable(mongoChart)
                .map(chartMapper::toDomainEntity);
    }

    @Override
    public Optional<Chart> findLatestGenreChart(Integer genreId) {
        Query query = Query.query(Criteria.where("genreId").is(genreId))
                .with(Sort.by(Sort.Direction.DESC, "createdAt"))
                .limit(1);

        MongoChart mongoChart = mongoTemplate.findOne(query, MongoChart.class, "charts");

        return Optional.ofNullable(mongoChart)
                .map(chartMapper::toDomainEntity);
    }
}
