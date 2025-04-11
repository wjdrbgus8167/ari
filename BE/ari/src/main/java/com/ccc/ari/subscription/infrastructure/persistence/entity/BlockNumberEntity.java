package com.ccc.ari.subscription.infrastructure.persistence.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigInteger;
import java.time.LocalDateTime;

@Entity
@Table(name = "block_numbers")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class BlockNumberEntity {

    @Id
    @Column(name = "event_type")
    private String eventType;

    @NotNull
    @Column(name = "last_processed_block")
    private BigInteger lastProcessedBlock;

    @NotNull
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Builder
    public BlockNumberEntity(String eventType, BigInteger lastProcessedBlock) {
        this.eventType = eventType;
        this.lastProcessedBlock = lastProcessedBlock;
        this.updatedAt = LocalDateTime.now();
    }
}
