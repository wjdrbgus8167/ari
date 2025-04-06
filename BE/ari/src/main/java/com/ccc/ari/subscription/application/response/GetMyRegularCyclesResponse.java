package com.ccc.ari.subscription.application.response;

import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class GetMyRegularCyclesResponse {

    private int cycleId;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
}
