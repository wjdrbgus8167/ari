package com.ccc.ari.chart.domain.client;

import java.time.Instant;
import java.util.List;

/**
 * IPFS에서 스트리밍 기록을 조회하는 인터페이스
 */
public interface ChartIpfsClient {

    /**
     * 특정 기간의 스트리밍 기록을 IPFS에서 조회
     *
     * @param start 시작 시간
     * @param end 종료 시간
     * @return 스트리밍 기록 목록
     */
    List<StreamingLogRecord> getStreamingLogs(Instant start, Instant end);
}
