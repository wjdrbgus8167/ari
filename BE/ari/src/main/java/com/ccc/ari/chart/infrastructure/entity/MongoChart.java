package com.ccc.ari.chart.infrastructure.entity;

import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Getter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

/**
 * MongoDB에 저장되는 차트 문서 엔티티
 */
@Document(collection = "charts")
@Getter
@Builder
public class MongoChart {

    @Id
    private String id;

    @Indexed
    private Integer genreId;  // null이면 전체 차트, 값이 있으면 해당 장르의 차트

    @Indexed
    private LocalDateTime createdAt;

    private List<MongoChartEntry> entries;

    /**
     * MongoDB에 저장되는 차트 엔트리 문서
     */
    @Getter
    @Builder
    public static class MongoChartEntry {
        private Integer trackId;
        private Long streamCount;
        private Integer rank;
    }
}
