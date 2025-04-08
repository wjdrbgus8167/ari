package com.ccc.ari.settlement.application.response;

import lombok.Builder;
import lombok.Getter;

@Getter
public class WalletStatusResponse {

    private Boolean hasWallet;

    @Builder
    public WalletStatusResponse(Boolean hasWallet) {
        this.hasWallet = hasWallet;
    }
}
