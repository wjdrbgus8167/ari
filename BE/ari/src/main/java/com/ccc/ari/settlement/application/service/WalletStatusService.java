package com.ccc.ari.settlement.application.service;

import com.ccc.ari.settlement.application.response.WalletStatusResponse;
import com.ccc.ari.settlement.domain.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class WalletStatusService {

    private final WalletRepository walletRepository;

    public WalletStatusResponse getWalletStatus(Integer memberId) {
        Boolean hasWallet = walletRepository.existsWalletByArtistId(memberId);

        return WalletStatusResponse.builder()
                .hasWallet(hasWallet)
                .build();
    }
}
