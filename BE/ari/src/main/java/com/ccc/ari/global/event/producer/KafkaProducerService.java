package com.ccc.ari.global.event.producer;

import com.ccc.ari.global.event.TrackPlayEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class KafkaProducerService {

    private final KafkaTemplate<String, TrackPlayEvent> kafkaTemplate;
    private static final String TOPIC = "track-play-event";

    public void sendTrackPlayEvent(TrackPlayEvent trackPlayEvent) {
        kafkaTemplate.send(TOPIC, trackPlayEvent);
    }
}
