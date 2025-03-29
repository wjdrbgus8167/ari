package com.ccc.ari.community.infrastructure.comment.repository;

import com.ccc.ari.community.infrastructure.comment.entity.TrackCommentJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrackCommentJpaRepository extends JpaRepository<TrackCommentJpaEntity, Integer> {
}
