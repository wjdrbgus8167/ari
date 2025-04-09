package com.ccc.ari.settlement.domain.repository;

import com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity.WalletEntity;

import java.util.List;

public interface WalletRepository {

    WalletEntity save(WalletEntity walletEntity);

    List<WalletEntity> getAllWallets();

    WalletEntity getWalletByArtistId(Integer artistId);

    Boolean existsWalletByArtistId(Integer artistId);
}
