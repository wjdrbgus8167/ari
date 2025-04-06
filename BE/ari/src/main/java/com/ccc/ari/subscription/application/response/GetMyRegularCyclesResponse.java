package com.ccc.ari.subscription.application.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class GetMyRegularCyclesResponse {

    private int cycleId;

    @JsonFormat(pattern = "yyyy.MM.dd HH:mm:ss")
    private LocalDateTime startedAt;

    @JsonFormat(pattern = "yyyy.MM.dd HH:mm:ss")
    private LocalDateTime endedAt;
}
