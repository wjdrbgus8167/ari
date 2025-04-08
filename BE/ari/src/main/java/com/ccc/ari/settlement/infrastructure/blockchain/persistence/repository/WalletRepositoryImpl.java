package com.ccc.ari.settlement.infrastructure.blockchain.persistence.repository;

import com.ccc.ari.settlement.domain.repository.WalletRepository;
import com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity.WalletEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class WalletRepositoryImpl implements WalletRepository {

    private final WalletJpaRepository walletJpaRepository;

    @Override
    public WalletEntity save(WalletEntity walletEntity) {
        return walletJpaRepository.save(walletEntity);
    }

    @Override
    public WalletEntity getWalletByArtistId(Integer artistId) {
        return walletJpaRepository.findByArtistId(artistId).orElse(null);
    }

    @Override
    public Boolean existsWalletByArtistId(Integer artistId) {
        return walletJpaRepository.existsByArtistId(artistId);
    }
}
