package com.ccc.ari.chart.domain.client;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.time.Instant;

@RequiredArgsConstructor
@Getter
public class StreamingLogRecord {

    private final Instant timestamp;
    private final Integer trackId;
    private final String trackTitle;
    private final Integer memberId;
    private final String memberNickname;

    @Override
    public String toString() {
        return timestamp.toString() + " - " +
                memberNickname + "(id:" + memberId + ") played " +
                trackTitle + "(id:" + trackId + ")";
    }
}
