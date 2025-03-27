package com.ccc.ari.playlist.domain.vo;

import lombok.Getter;

@Getter
public class TrackOrder {
    private final int value;

    private TrackOrder(int value) {
        if (value < 0) throw new IllegalArgumentException("trackOrder는 1 이상이어야 합니다.");
        this.value = value;
    }

    public static TrackOrder from(int value) {
        return new TrackOrder(value);
    }

    public int getValue() {
        return value;
    }

    public TrackOrder next() {
        return new TrackOrder(value + 1);
    }
}
