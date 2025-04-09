package com.ccc.ari.settlement.infrastructure.blockchain.persistence.repository;

import com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity.WalletEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WalletJpaRepository extends JpaRepository<WalletEntity, Integer> {

    Optional<WalletEntity> findByArtistId(Integer artistId);

    Optional<List<WalletEntity>> getAll();

    Boolean existsByArtistId(Integer artistId);
}
