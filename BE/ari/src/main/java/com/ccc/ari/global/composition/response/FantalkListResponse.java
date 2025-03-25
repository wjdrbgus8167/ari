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
                        .memberName("더미 작성자 이름")
                        .profileImageUrl("더미 작성자 프로필")
                        .content(fantalk.getContent())
                        .fantalkImageUrl(fantalk.getFantalkImageUrl())
                        .track(fantalk.getTrackId() != null ? placeholderTrack(fantalk.getTrackId()) : null)
                        .createdAt(fantalk.getCreatedAt())
                        .build())
                .toList();

        return FantalkListResponse.builder()
                .fantalks(fantalkItems)
                .fantalkCount(fantalks.size())
                .build();
    }

    /**
     * 임시 트랙 정보 생성
     * TODO: 트랙 Client 구현 시 수정하겠습니다.
     */
    private static TrackItem placeholderTrack(Integer trackId) {
        return TrackItem.builder()
                .trackId(trackId)
                .trackName("더미 트랙")
                .artist("더미 아티스트 이름")
                .coverImageUrl(null)
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
        private String memberName;
        private String profileImageUrl;
        private String content;
        private String fantalkImageUrl;
        private TrackItem track;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
        private LocalDateTime createdAt;
    }

    /**
     * 트랙 정보를 담는 내부 클래스
     */
    @Getter
    @Builder
    public static class TrackItem {
        private Integer trackId;
        private String trackName;
        private String artist;
        private String coverImageUrl;
    }
}
