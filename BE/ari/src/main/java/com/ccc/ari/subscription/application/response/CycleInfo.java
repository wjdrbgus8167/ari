package com.ccc.ari.subscription.application.response;

import com.ccc.ari.global.type.PlanType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@Builder
public class CycleInfo {

    private int cycleId;
    private PlanType planType;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
}
