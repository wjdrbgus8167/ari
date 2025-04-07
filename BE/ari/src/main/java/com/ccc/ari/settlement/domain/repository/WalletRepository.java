package com.ccc.ari.settlement.domain.repository;

import com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity.WalletEntity;

public interface WalletRepository {

    WalletEntity save(WalletEntity walletEntity);

    WalletEntity getWalletByArtistId(Integer artistId);
}
