package com.ccc.ari.global.composition.response.community;

import com.ccc.ari.community.domain.fantalk.client.FantalkDto;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.track.TrackDto;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 팬톡 목록 조회 응답 DTO
 */
@Getter
@Builder
public class FantalkListResponse {

    private List<FantalkItem> fantalks;
    private int fantalkCount;

    public static FantalkListResponse from(List<FantalkDto> fantalks, Map<Integer, MemberDto> memberMap, Map<Integer, TrackDto> trackMap, Map<Integer, AlbumDto> albumMap) {
        List<FantalkItem> fantalkItems = fantalks.stream()
                .map(fantalk -> {

                    // 회원 정보 조회
                    MemberDto member = memberMap.get(fantalk.getMemberId());
                    String memberName = member.getNickname();
                    String profileImageUrl = member.getProfileImageUrl();

                    // 트랙 정보 조회
                    TrackItem trackItem = null;
                    if (fantalk.getTrackId() != null) {
                        TrackDto track = trackMap.get(fantalk.getTrackId());
                        if (track != null) {
                            // 앨범 정보 조회
                            AlbumDto album = albumMap.get(track.getAlbumId());
                            String artistName = album.getArtist();
                            String coverImageUrl = album.getCoverImageUrl();

                            trackItem = TrackItem.builder()
                                    .trackId(track.getTrackId())
                                    .trackName(track.getTitle())
                                    .artist(artistName)
                                    .coverImageUrl(coverImageUrl)
                                    .build();
                        }
                    }

                    return FantalkItem.builder()
                            .fantalkId(fantalk.getFantalkId())
                            .memberId(fantalk.getMemberId())
                            .memberName(memberName)
                            .profileImageUrl(profileImageUrl)
                            .content(fantalk.getContent())
                            .fantalkImageUrl(fantalk.getFantalkImageUrl())
                            .track(trackItem)
                            .createdAt(fantalk.getCreatedAt())
                            .build();
                })
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
        private String memberName;
        private String profileImageUrl;
        private String content;
        private String fantalkImageUrl;
        private TrackItem track;

        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
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
