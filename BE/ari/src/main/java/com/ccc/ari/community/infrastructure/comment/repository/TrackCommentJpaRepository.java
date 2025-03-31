package com.ccc.ari.community.infrastructure.comment.repository;

import com.ccc.ari.community.infrastructure.comment.entity.TrackCommentJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TrackCommentJpaRepository extends JpaRepository<TrackCommentJpaEntity, Integer> {
    Optional<List<TrackCommentJpaEntity>> findAllByTrackIdAndDeletedYnFalseOrderByCreatedAtDesc(Integer trackId);

    int countAllByTrackIdAndDeletedYnFalse(Integer trackId);
}
