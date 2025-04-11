package com.ccc.ari.community.infrastructure.comment.repository;

import com.ccc.ari.community.infrastructure.comment.entity.AlbumCommentJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlbumCommentJpaRepository extends JpaRepository<AlbumCommentJpaEntity, Integer> {
    Optional<List<AlbumCommentJpaEntity>> findAllByAlbumIdAndDeletedYnFalseOrderByCreatedAtDesc(Integer albumId);
}
