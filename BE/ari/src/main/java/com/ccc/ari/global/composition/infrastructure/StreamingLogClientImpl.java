package com.ccc.ari.global.composition.infrastructure;

import com.ccc.ari.aggregation.application.service.StreamingLogQueryService;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/*
 트랙 StreamingLog 조회 Client
 TODO : 아직 임시로 구현됨. 추후 상의 후 수정 or 변경될듯
 */
@Component
@RequiredArgsConstructor
public class StreamingLogClientImpl {

    private final StreamingLogQueryService streamingLogQueryService;

    public List<StreamingLog> getStreamingLog(Integer trackId) {

        return streamingLogQueryService.findStreamingLogByTrackId(trackId);
    }
}
