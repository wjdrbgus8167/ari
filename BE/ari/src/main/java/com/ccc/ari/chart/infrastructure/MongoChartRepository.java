package com.ccc.ari.chart.infrastructure;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MongoChartRepository extends MongoRepository<ChartDocument, String> {

    // 가장 최근에 생성된 차트 조회
    Optional<ChartDocument> findTopByOrderByCreatedAtDesc();
}
