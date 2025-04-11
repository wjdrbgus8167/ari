package com.ccc.ari.community.domain.follow.client;

import com.ccc.ari.community.domain.follow.entity.Follow;
import lombok.Builder;
import lombok.Getter;

/**
 * 팔로잉 목록 데이터 전송 객체
 */
@Getter
@Builder
public class FollowingDto {

    private Integer followingId;

    /**
     * 도메인 엔티티를 DTO로 변환하는 메서드
     */
    public static FollowingDto from(Follow follow) {
        return FollowingDto.builder()
                .followingId(follow.getFollowingId())
                .build();
    }
}
