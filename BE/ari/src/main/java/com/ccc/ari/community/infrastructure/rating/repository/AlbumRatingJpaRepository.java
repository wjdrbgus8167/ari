package com.ccc.ari.community.infrastructure.rating.repository;

import com.ccc.ari.community.infrastructure.rating.entity.AlbumRatingJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlbumRatingJpaRepository extends JpaRepository<AlbumRatingJpaEntity, Integer> {

    Optional<AlbumRatingJpaEntity> findByMemberIdAndAlbumId(Integer memberId, Integer albumId);

    List<AlbumRatingJpaEntity> findAllByAlbumId(Integer albumId);

    void deleteByMemberIdAndAlbumId(Integer memberId, Integer albumId);

}
