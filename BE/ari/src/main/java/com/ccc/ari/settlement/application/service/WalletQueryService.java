package com.ccc.ari.settlement.application.service;

import com.ccc.ari.settlement.domain.repository.WalletRepository;
import com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity.WalletEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class WalletQueryService {

    private final WalletRepository walletRepository;

    public WalletEntity getWalletByArtistId(Integer artistId) {
        return walletRepository.getWalletByArtistId(artistId);
    }
}
