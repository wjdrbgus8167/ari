package com.ccc.ari.community.infrastructure.like.repository;

import com.ccc.ari.community.infrastructure.like.entity.AlbumLikeJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AlbumLikeJpaRepository extends JpaRepository<AlbumLikeJpaEntity, Integer> {
    Optional<AlbumLikeJpaEntity> findByAlbumIdAndMemberId(Integer albumId, Integer memberId);
}
