package com.ccc.ari.community.domain.follow.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Objects;

/**
 * 팔로우 관계의 유효성을 검증하는 도메인 서비스
 */
@Service
@RequiredArgsConstructor
public class FollowValidatorService {

    /**
     * 자신을 팔로우하는 지 검증하는 메서드
     * @param followerId 팔로우 하는 회원 ID
     * @param followingId 팔로우 당하는 회원 ID
     */
    public void validateSelfFollow(Integer followerId, Integer followingId) {
        if (Objects.equals(followerId, followingId)) {
            throw new IllegalArgumentException("자신을 팔로우할 수 없습니다.");
        }
    }
}
