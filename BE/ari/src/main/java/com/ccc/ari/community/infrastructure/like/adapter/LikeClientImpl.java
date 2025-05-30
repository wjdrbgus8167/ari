package com.ccc.ari.community.infrastructure.like.adapter;

import com.ccc.ari.community.application.like.repository.LikeRepository;
import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.client.LikeClient;
import com.ccc.ari.community.domain.like.entity.Like;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class LikeClientImpl implements LikeClient {

    private final LikeRepository likeRepository;

    @Override
    public Boolean isLiked(Integer targetId, Integer memberId, LikeType type) {
        return likeRepository.existsActiveByTargetAndMember(targetId, memberId, type);
    }

    @Override
    public Optional<Like> findByTargetAndMember(Integer targetId, Integer memberId, LikeType type) {
        return likeRepository.findByTargetAndMember(targetId, memberId, type);
    }

    @Override
    public void saveLike(Like like, LikeType type) {
        likeRepository.saveLike(like, type);
    }

    @Override
    public List<Like> findAllByMember(Integer memberId, LikeType type) {
        return likeRepository.findAllByMember(memberId, type);
    }
}
