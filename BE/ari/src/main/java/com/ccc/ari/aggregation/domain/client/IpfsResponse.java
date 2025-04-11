package com.ccc.ari.aggregation.domain.client;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Getter
public class IpfsResponse {
    private final String cid;

    @Override
    public String toString() {
        return "IpfsResponse{" +
                "cid='" + cid + '\'' + "}";
    }
}
