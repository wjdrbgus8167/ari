package com.ccc.ari.exhibition.event;

import com.ccc.ari.event.common.Event;
import lombok.Getter;

import java.time.Instant;

/**
 * 전시 도메인에서 집계 도메인에 데이터를 요청하기 위한 이벤트
 * 인기 앨범 및 트랙 갱신에 필요한 스트리밍 데이터를 요청합니다.
 */
@Getter
public class PopularTracksRequestEvent implements Event {

    public enum DataType {
        ALL,
        GENRE
    }

    private final DataType dataType;      // 요청하는 데이터 유형
    private final Integer genreId;        // 장르 ID
    private final Instant fromTimestamp;  // 조회 시작 시간
    private final Instant toTimestamp;    // 조회 종료 시간

    /**
     * 전체 스트리밍 데이터 요청을 위한 생성자
     *
     * @param fromTimestamp 조회 시작 시간
     * @param toTimestamp 조회 종료 시간
     */
    public PopularTracksRequestEvent(Instant fromTimestamp, Instant toTimestamp) {
        this.dataType = DataType.ALL;
        this.genreId = null;
        this.fromTimestamp = fromTimestamp;
        this.toTimestamp = toTimestamp;
    }

    /**
     * 장르별 스트리밍 데이터 요청을 위한 생성자
     *
     * @param genreId 장르 ID
     * @param fromTimestamp 조회 시작 시간
     * @param toTimestamp 조회 종료 시간
     */
    public PopularTracksRequestEvent(Integer genreId, Instant fromTimestamp, Instant toTimestamp) {
        if (genreId == null) {
            throw new IllegalArgumentException("장르별 데이터 요청 시 genreId는 필수입니다.");
        }
        this.dataType = DataType.GENRE;
        this.genreId = genreId;
        this.fromTimestamp = fromTimestamp;
        this.toTimestamp = toTimestamp;
    }
}
