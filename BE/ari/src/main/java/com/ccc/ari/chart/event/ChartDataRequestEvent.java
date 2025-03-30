package com.ccc.ari.chart.event;

import com.ccc.ari.event.common.Event;
import lombok.Getter;

import java.time.Instant;

/**
 * 차트 도메인에서 집계 도메인에 데이터를 요청하기 위한 이벤트
 * 차트 갱신에 필요한 스트리밍 데이터를 요청합니다.
 */
@Getter
public class ChartDataRequestEvent implements Event {

    public enum ChartType {
        ALL,   // 전체 차트
        GENRE  // 장르별 차트
    }

    private final ChartType chartType;  // 요청하는 차트 유형
    private final Integer genreId;      // 장르별 차트의 경우 genreId
    private final Instant timestamp;    // 요청하는 시간

    /**
     * 전체 차트 데이터 요청을 위한 생성자
     *
     * @param timestamp 요청하는 시간
     */
    public ChartDataRequestEvent(Instant timestamp) {
        this.chartType = ChartType.ALL;
        this.genreId = null;
        this.timestamp = timestamp;
    }

    /**
     * 장르별 차트 데이터 요청을 위한 생성자
     *
     * @param genreId 요청할 장르 ID
     * @param timestamp 요청하는 시간
     */
    public ChartDataRequestEvent(Integer genreId, Instant timestamp) {
        if (genreId == null) {
            throw new IllegalArgumentException("장르별 차트 요청 시 genreId는 필수입니다.");
        }
        this.chartType = ChartType.GENRE;
        this.genreId = genreId;
        this.timestamp = timestamp;
    }
}


