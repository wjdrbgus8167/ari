package com.ccc.ari.aggregation.application.repository;

import com.ccc.ari.aggregation.domain.vo.StreamingLog;

import java.util.List;

public interface StreamingLogRepository {

    void saveStreamingLogs(String key, StreamingLog streamingLog);

    /**
     * 키에 저장된 모든 StreamingLog를 조회하고 삭제합니다.
     * IPFS에 영구 저장하기 전에 배치 처리를 위해 사용됩니다.
     *
     * @param key Redis에 저장된 리스트의 키
     * @return 조회된 모든 StreamingLog 객체 리스트
     */
    List<StreamingLog> getAllAndDelete(String key);
}
