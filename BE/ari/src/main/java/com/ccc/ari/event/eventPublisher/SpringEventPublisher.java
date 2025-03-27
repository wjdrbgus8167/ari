package com.ccc.ari.event.eventPublisher;

import com.ccc.ari.event.common.Event;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SpringEventPublisher implements EventPublisher {

    private final ApplicationEventPublisher eventPublisher;

    @Override
    public void publish(Event event) {
        eventPublisher.publishEvent(event);
    }
}