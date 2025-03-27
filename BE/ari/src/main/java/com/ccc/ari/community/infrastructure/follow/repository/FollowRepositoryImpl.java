package com.ccc.ari.community.infrastructure.follow.repository;

import com.ccc.ari.community.application.follow.repository.FollowRepository;
import com.ccc.ari.community.domain.follow.entity.Follow;
import com.ccc.ari.community.infrastructure.follow.entity.FollowJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class FollowRepositoryImpl implements FollowRepository {

    private final FollowJpaRepository followJpaRepository;

    @Override
    public void saveFollow(Follow follow) {
        FollowJpaEntity entity = FollowJpaEntity.fromDomain(follow);
        followJpaRepository.save(entity);
    }

    @Override
    public Optional<Follow> findByIds(Integer followerId, Integer followingId) {
        return followJpaRepository.findByFollowerIdAndFollowingId(followerId, followingId)
                .map(FollowJpaEntity::toDomain);
    }
}
