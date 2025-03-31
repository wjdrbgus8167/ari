package com.ccc.ari.aggregation.event;

import lombok.Getter;

/**
 * AggregationOnChainApplicationService가 집계 데이터를 온체인 커밋한 이후,
 * AggregationCalculatorService를 호출하기 위한 이벤트입니다.
 */
@Getter
public class OnChainCommitCompletedEvent {

    // 해당 집계가 이루어진 이벤트의 트랜잭션 해쉬
    private final String txHash;

    public OnChainCommitCompletedEvent(String txHash) {
        this.txHash = txHash;
    }
}
