package com.ccc.ari.community.domain.fantalk.client;

import com.ccc.ari.community.domain.fantalk.entity.Fantalk;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

/**
 * 팬톡 도메인의 데이터 전송 객체
 * Composition 레이어와의 통신에 사용됩니다.
 */
@Getter
@Builder
public class FantalkDto {

    private Integer fantalkId;
    private Integer fantalkChannelId;
    private Integer memberId;
    private String content;
    private Integer trackId;
    private String fantalkImageUrl;
    private LocalDateTime createdAt;

    /**
     * 도메인 엔티티를 DTO로 변환하는 메서드
     */
    public static FantalkDto from(Fantalk fantalk) {
        return FantalkDto.builder()
                .fantalkId(fantalk.getFantalkId())
                .fantalkChannelId(fantalk.getFantalkChannelId())
                .memberId(fantalk.getMemberId())
                .content(fantalk.getContent().getContent())
                .trackId(fantalk.getContent().getTrackId())
                .fantalkImageUrl(fantalk.getContent().getFantalkImageUrl())
                .createdAt(fantalk.getCreatedAt())
                .build();
    }
}
