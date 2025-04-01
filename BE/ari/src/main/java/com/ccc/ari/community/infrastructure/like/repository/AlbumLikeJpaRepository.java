package com.ccc.ari.community.infrastructure.like.repository;

import com.ccc.ari.community.infrastructure.like.entity.AlbumLikeJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AlbumLikeJpaRepository extends JpaRepository<AlbumLikeJpaEntity, Integer> {
    Optional<AlbumLikeJpaEntity> findByAlbumIdAndMemberId(Integer albumId, Integer memberId);

    Boolean existsByAlbumIdAndMemberIdAndActivateYnTrue(Integer albumId, Integer memberId);
}
