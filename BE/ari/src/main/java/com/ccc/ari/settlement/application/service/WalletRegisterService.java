package com.ccc.ari.settlement.application.service;

import com.ccc.ari.global.event.ArtistRegisteredEvent;
import com.ccc.ari.settlement.domain.repository.WalletRepository;
import com.ccc.ari.settlement.infrastructure.blockchain.persistence.entity.WalletEntity;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class WalletRegisterService {
    
    private final WalletRepository walletRepository;
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Transactional
    @EventListener
    public void registerWallet(ArtistRegisteredEvent event) {
        logger.info("지갑 등록 시작. 아티스트 ID: {}, 주소: {}", event.getArtistId(), event.getAddress());
        walletRepository.save(WalletEntity.builder()
                .artistId(event.getArtistId())
                .address(event.getAddress())
                .build());
        logger.info("지갑 등록 완료. 아티스트 ID: {}", event.getArtistId());
    }
}
