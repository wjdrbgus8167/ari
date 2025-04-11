package com.ccc.ari.community.application.follow.service;

import com.ccc.ari.community.application.follow.repository.FollowRepository;
import com.ccc.ari.community.domain.follow.entity.Follow;
import com.ccc.ari.community.domain.follow.service.FollowValidatorService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class FollowService {

    private final FollowValidatorService followValidatorService;
    private final FollowRepository followRepository;

    /**
     * 팔로우
     * @param followerId 팔로우 하는 회원 ID
     * @param followingId 팔로우 당하는 회원 ID
     */
    @Transactional
    public void follow(Integer followerId, Integer followingId) {
        // 1. 자기 자신을 팔로우하는지 검증합니다.
        followValidatorService.validateSelfFollow(followerId, followingId);

        // 2. 팔로우 관게를 조회합니다.
        Optional<Follow> follow = followRepository.findByIds(followerId, followingId);

        // 3. 팔로우 관계를 저장합니다.
        // - 비활성화된 관계는 활성화
        // - 처음 팔로우하는 사람은 관계 생성
        if (follow.isPresent()) {
            Follow existingFollow = follow.get();

            if (existingFollow.getActivateYn()) {
                throw new IllegalStateException("이미 팔로우하고 있는 사용자입니다.");
            }

            existingFollow.activate();
            followRepository.saveFollow(existingFollow);
        } else {
            Follow newFollow = Follow.builder()
                    .followerId(followerId)
                    .followingId(followingId)
                    .createdAt(LocalDateTime.now())
                    .build();
            followRepository.saveFollow(newFollow);
        }
    }

    /**
     * 팔로우 취소
     * @param followerId 팔로우 취소하는 회원 ID
     * @param followingId 팔로우 취소할 회원 ID
     */
    @Transactional
    public void unfollow(Integer followerId, Integer followingId) {
        // 1. 팔로우 관계의 유효성을 검증합니다.
        Follow follow = followRepository.findByIds(followerId, followingId)
                .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 팔로우 관계입니다."));

        // 2. 활성화된 팔로우 관계인지 확인합니다.
        if (!follow.getActivateYn()) {
            throw new IllegalStateException("이미 팔로우가 취소된 상태입니다.");
        }

        // 2. 팔로우 관계를 비활성화합니다.
        follow.deactivate();
        followRepository.saveFollow(follow);
    }
}
