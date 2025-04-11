package com.ccc.ari.settlement.ui.client;

import com.ccc.ari.settlement.application.service.WalletQueryService;
import com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity.WalletEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class WalletClient {

    private final WalletQueryService walletQueryService;

    public WalletEntity getWalletByArtistId(Integer artistId) {
        return walletQueryService.getWalletByArtistId(artistId);
    }
}
