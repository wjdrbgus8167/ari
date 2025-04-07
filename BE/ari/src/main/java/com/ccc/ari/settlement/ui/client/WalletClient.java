package com.ccc.ari.settlement.ui.client;

import com.ccc.ari.settlement.application.service.WalletQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class WalletClient {

    private final WalletQueryService walletQueryService;

    public void getWalletByArtistId(Integer artistId) {
        walletQueryService.getWalletByArtistId(artistId);
    }
}
