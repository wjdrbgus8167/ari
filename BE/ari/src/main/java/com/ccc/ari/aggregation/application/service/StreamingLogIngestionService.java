package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.application.repository.StreamingLogRepository;
import com.ccc.ari.aggregation.domain.service.StreamingLogCollectorService;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.global.event.StreamingEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class StreamingLogIngestionService {

    private final StreamingLogCollectorService collectorService;
    private final StreamingLogRepository streamingLogRepository;
    private static final Logger logger = LoggerFactory.getLogger(StreamingLogIngestionService.class);

    /**
     * 음원 컴포넌트에서 전달된 StreamingEvent를 도메인 서비스로 변환하고,
     * 이를 Redis에 임시 저장합니다.
     *
     * @param event 외부에서 수신된 스트리밍 이벤트
     */
    @EventListener
    public void ingestEvent(StreamingEvent event) {
        logger.info("수신된 StreamingEvent: timestamp={}, memberId={}, nickname={}, trackId={}, trackTitle={}",
                event.getTimestamp(), event.getMemberId(), event.getNickname(), event.getTrackId(), event.getTrackTitle());

        // 1. StreamingLogCollectorService를 사용해 StreamingLog VO로 변환
        StreamingLog streaminglog = collectorService.createStreamingLog(event);
        // 2. Redis 저장 (배치 키 "currentBatch")
        streamingLogRepository.saveStreamingLogs("currentBatch", streaminglog);
        logger.info("StreamingLog Redis 저장 완료: key={}, log={}", "currentBatch", streaminglog);
    }
}
