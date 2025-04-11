package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.domain.repository.BlockNumberRepository;
import com.ccc.ari.subscription.infrastructure.persistence.entity.BlockNumberEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.math.BigInteger;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class BlockNumberRepositoryImpl implements BlockNumberRepository {

    private final BlockNumberJpaRepository blockNumberJpaRepository;


    @Override
    public void saveLastProcessedBlock(String eventType, BigInteger lastProcessedBlock) {
        blockNumberJpaRepository.save(new BlockNumberEntity(eventType, lastProcessedBlock));
    }

    @Override
    public Optional<BigInteger> getLastProcessedBlockNumber(String eventType) {
        return blockNumberJpaRepository.findById(eventType).isPresent() ?
                Optional.of(blockNumberJpaRepository.findById(eventType).get().getLastProcessedBlock()) :
                Optional.empty();
    }
}
