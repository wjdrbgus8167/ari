package com.ccc.ari.community.infrastructure.like.repository;

import com.ccc.ari.community.infrastructure.like.entity.TrackLikeJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TrackLikeJpaRepository extends JpaRepository<TrackLikeJpaEntity, Integer> {
    Optional<TrackLikeJpaEntity> findByTrackIdAndMemberId(Integer trackId, Integer memberId);
}
