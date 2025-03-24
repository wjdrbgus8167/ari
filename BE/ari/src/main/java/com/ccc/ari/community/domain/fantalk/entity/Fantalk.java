package com.ccc.ari.community.domain.fantalk.entity;

import com.ccc.ari.community.domain.fantalk.vo.FantalkContent;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

/**
 * Fantalk 도메인 엔티티
 */
@Builder
@Getter
public class Fantalk {

    private Integer fantalkId;
    private Integer fantalkChannelId;
    private Integer memberId;
    private LocalDateTime createdAt;
    private FantalkContent content;

    public Fantalk(Integer fantalkId, Integer fantalkChannelId, Integer memberId, LocalDateTime createdAt, FantalkContent content) {
        this.fantalkId = fantalkId;
        this.fantalkChannelId = fantalkChannelId;
        this.memberId = memberId;
        this.createdAt = createdAt;
        this.content = content;
    }
}
