package com.ccc.ari.exhibition.infrastructure.entity;

import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Getter;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

/**
 * MongoDB에 저장되는 인기 아이템 문서 엔티티
 */
@Document(collection = "exhibitions")
@Getter
@Builder
public class MongoPopularItem {

    @Id
    private String id;

    @Indexed
    private String itemType;

    @Indexed
    private Integer genreId;

    @Indexed
    private LocalDateTime createdAt;

    private List<MongoPopularEntry> entries;

    @Getter
    @Builder
    public static class MongoPopularEntry {
        private Integer itemId;
        private Long count;
    }
}
