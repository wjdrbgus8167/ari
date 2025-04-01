package com.ccc.ari.community.infrastructure.like.adapter;

import com.ccc.ari.community.application.like.repository.LikeRepository;
import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.client.LikeClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LikeClientImpl implements LikeClient {

    private final LikeRepository likeRepository;

    @Override
    public Boolean isLiked(Integer targetId, Integer memberId, LikeType type) {
        return likeRepository.existsActiveByTargetAndMember(targetId, memberId, type);
    }
}
