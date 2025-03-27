package com.ccc.ari.aggregation.event;

import com.ccc.ari.aggregation.domain.AggregatedData;
import lombok.Getter;

/**
 * AggregationBatchService가 AggregatedData를 생성한 이후,
 * AggregationOnChainApplicationService를 호출하기 위한 이벤트입니다.
 */
@Getter
public class AggregationCompletedEvent {

    // 집계 단위를 구분하는 enum
    public enum AggregationType {
        ALL,    // 전체 데이터 집계
        GENRE,  // 장르별 데이터 집계
        ARTIST, // 아티스트별 데이터 집계
        LISTENER // 리스너별 데이터 집계
    }

    private final AggregationType aggregationType;
    private final AggregatedData aggregatedData;
    private final Integer specificId;

    public AggregationCompletedEvent(AggregationType aggregationType,
                                     AggregatedData aggregatedData,
                                     Integer specificId) {
        validateIdForType(aggregationType, specificId);
        this.aggregationType = aggregationType;
        this.aggregatedData = aggregatedData;
        this.specificId = specificId;

    }

    // 이벤트 타입에 따라 ID 존재 여부 검증
    private void validateIdForType(AggregationType type, Integer id) {
        if (type != AggregationType.ALL && id == null) {
            throw new IllegalArgumentException(type + " 타입의 이벤트는 specificId가 필수입니다.");
        }
    }

    // ALL 타입일 경우 ID가 null임을 보장하는 생성자
    public AggregationCompletedEvent(AggregatedData aggregatedData) {
        this.aggregationType = AggregationType.ALL;
        this.aggregatedData = aggregatedData;
        this.specificId = null;
    }
}