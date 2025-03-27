package com.ccc.ari.community.domain.follow.client;

import com.ccc.ari.community.domain.follow.entity.Follow;
import lombok.Builder;
import lombok.Getter;

/**
 * 팔로워 목록 데이터 전송 객체
 */
@Getter
@Builder
public class FollowerDto {

    private Integer followerId;

    /**
     * 도메인 엔티티를 DTO로 변환하는 메서드
     */
    public static FollowerDto from(Follow follow) {
        return FollowerDto.builder()
                .followerId(follow.getFollowerId())
                .build();
    }
}
