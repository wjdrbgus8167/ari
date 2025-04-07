package com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "wallets")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class WalletEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "wallet_id")
    private Integer walletId;

    @NotNull
    @Column(name = "artist_id")
    private Integer artistId;

    @NotNull
    @Column(name = "address")
    private String address;

    @Builder
    public WalletEntity(Integer artistId, String address) {
        this.artistId = artistId;
        this.address = address;
    }
}
