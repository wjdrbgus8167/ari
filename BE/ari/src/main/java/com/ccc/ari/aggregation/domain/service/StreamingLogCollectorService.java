package com.ccc.ari.aggregation.domain.service;

import com.ccc.ari.aggregation.domain.vo.AggregationPeriod;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import org.springframework.kafka.annotation.KafkaListener;

/**
 * StreamingLogCollectorService는 kakfa에서 전달된 StreamingEvent를
 * 도메인 VO인 StreamingLog로 변환하는 책임을 집니다.
 */
public class StreamingLogCollectorService {

    /**
     * StreamingEvent를 받아 해당 정보를 StreamingLog VO로 생성합니다.
     *
     * @param period 해당 집계 단위의 집계 기간
     * @param event 수신된 스트리밍 이벤트
     * @return 변환된 StreamingLog 객체
     * @throws IllegalArgumentException 이벤트가 null인 경우
     */
    @KafkaListener(topics = "streaming-event", groupId = "streaming-group")
    public StreamingLog createStreamingLog(AggregationPeriod period, StreamingEvent event) {
        if (event == null) {
            throw new IllegalArgumentException("StreamingEvent가 null입니다!!");
        }

        // 이벤트가 해당 집계 단위 시간 내에 발생했는지 검증
        if (event.getTimestamp().isBefore(period.getStart())
                || event.getTimestamp().isAfter(period.getEnd())) {
            throw new IllegalArgumentException("StreamingEvent의 시간(" + event.getTimestamp()
                    + ")이 집계 기간(" + period.getStart() + " ~ " + period.getEnd()
                    + ")에 포함되지 않습니다.");
        }

        // TODO: 추후 인증 구현 시 필드 검증 로직을 추가하겠습니다.
        return new StreamingLog(event.getTimestamp(),
                                event.getMemberId(), event.getMemberNickname(),
                                event.getTrackId(), event.getTrackTitle());
    }
}
