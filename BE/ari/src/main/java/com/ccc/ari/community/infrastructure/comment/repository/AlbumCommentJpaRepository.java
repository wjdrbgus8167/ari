package com.ccc.ari.community.infrastructure.comment.repository;

import com.ccc.ari.community.infrastructure.comment.entity.AlbumCommentJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AlbumCommentJpaRepository extends JpaRepository<AlbumCommentJpaEntity, Integer> {
    List<AlbumCommentJpaEntity> findAllByAlbumId(Integer albumId);
}
