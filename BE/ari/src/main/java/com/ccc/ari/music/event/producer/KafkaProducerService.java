package com.ccc.ari.music.event.producer;

import com.ccc.ari.global.event.StreamingEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class KafkaProducerService {

    private final KafkaTemplate<String, StreamingEvent> kafkaTemplate;
    private static final String TOPIC = "streaming-event";

    public void sendStreamingEvent(StreamingEvent streamingEvent) {
        kafkaTemplate.send(TOPIC, "user-" + streamingEvent.getMemberId(), streamingEvent);
    }
}
