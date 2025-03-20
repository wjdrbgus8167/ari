package com.ccc.ari.chart.infrastructure;

import com.ccc.ari.chart.domain.client.ChartIpfsClient;
import com.ccc.ari.chart.domain.client.StreamingLogRecord;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

@Component
public class ChartIpfsClientImpl implements ChartIpfsClient {

    @Override
    public List<StreamingLogRecord> getStreamingLogs(Instant start, Instant end) {
        // TODO: IPFS에서 스트리밍 로그 조회 로직 구현
        return null;
    }
}
