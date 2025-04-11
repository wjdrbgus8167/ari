package com.ccc.ari.settlement.application.command;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class GetMySettlementsForDateCommand {

    private final Integer artistId;
    private final Integer year;
    private final Integer month;
    private final Integer day;
}
