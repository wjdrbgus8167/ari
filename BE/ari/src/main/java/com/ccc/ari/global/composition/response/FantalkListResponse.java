package com.ccc.ari.global.composition.response;

import com.ccc.ari.community.domain.fantalk.client.FantalkDto;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 팬톡 목록 조회 응답 DTO
 */
@Getter
@Builder
public class FantalkListResponse {

    private List<FantalkItem> fantalks;
    private int fantalkCount;

    public static FantalkListResponse from(List<FantalkDto> fantalks) {
        List<FantalkItem> fantalkItems = fantalks.stream()
                .map(fantalk -> FantalkItem.builder()
                        .fantalkId(fantalk.getFantalkId())
                        .memberId(fantalk.getMemberId())
                        .content(fantalk.getContent())
                        .fantalkImageUrl(fantalk.getFantalkImageUrl())
                        .trackId(fantalk.getTrackId())
                        .createdAt(fantalk.getCreatedAt())
                        .build())
                .toList();

        return FantalkListResponse.builder()
                .fantalks(fantalkItems)
                .fantalkCount(fantalks.size())
                .build();
    }

    /**
     * 팬톡 상세 정보를 담는 내부 클래스
     */
    @Getter
    @Builder
    public static class FantalkItem {
        private Integer fantalkId;
        private Integer memberId;
        private String content;
        private String fantalkImageUrl;
        private Integer trackId;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
        private LocalDateTime createdAt;
    }
}
