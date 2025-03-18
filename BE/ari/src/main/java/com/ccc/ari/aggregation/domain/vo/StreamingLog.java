package com.ccc.ari.aggregation.domain.vo;

import lombok.Getter;

import java.time.Instant;
import java.util.Objects;

@Getter
public class StreamingLog {

    // 언제
    private final Instant timestamp; // UTC 기준 시간
    // 누가
    private final Integer memberId;
    private final String memberNickname;
    // 무엇을
    private final Integer trackId;
    private final String trackTitle;

    public StreamingLog(Instant timestamp, Integer memberId, String memberNickname, Integer trackId, String trackTitle) {
      this.timestamp = timestamp;
      this.memberId = memberId;
      this.memberNickname = memberNickname;
      this.trackId = trackId;
      this.trackTitle = trackTitle;
    }

    @Override
    public String toString() {
        return timestamp.toString() + " " +
                memberNickname + "(id:" + memberId + ") " +
                trackTitle + "(id:" + trackId + ")";
    }

    @Override
    public boolean equals(Object obj) {
        if(obj instanceof StreamingLog log) {
            return log.getTimestamp().equals(timestamp) &&
                    log.getMemberId().equals(memberId) &&
                    log.getMemberNickname().equals(memberNickname) &&
                    log.getTrackId().equals(trackId) &&
                    log.getTrackTitle().equals(trackTitle);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(timestamp, memberId, memberNickname, trackId, trackTitle);
    }
}
