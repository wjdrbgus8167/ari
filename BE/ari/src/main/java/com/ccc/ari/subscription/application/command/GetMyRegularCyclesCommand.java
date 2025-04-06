package com.ccc.ari.subscription.application.command;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class GetMyRegularCyclesCommand {

    private final Integer memberId;
}
