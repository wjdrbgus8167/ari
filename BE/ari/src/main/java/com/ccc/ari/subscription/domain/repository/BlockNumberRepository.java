package com.ccc.ari.subscription.domain.repository;

import java.math.BigInteger;
import java.util.Optional;

public interface BlockNumberRepository {

    /**
     * 특정 이벤트를 마지막으로 처리한 시점의 블록 넘버를 저장합니다.
     * */
    void saveLastProcessedBlock(String eventType, BigInteger lastProcessedBlock);

    /**
     * 마지막으로 특정 이벤트를 처리했던 블록의 번호를 반환합니다.
     */
    Optional<BigInteger> getLastProcessedBlockNumber(String eventType);
}
