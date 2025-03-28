package com.ccc.ari.community.infrastructure.like.repository;

import com.ccc.ari.community.application.like.repository.AlbumLikeRepository;
import com.ccc.ari.community.domain.like.entity.AlbumLike;
import com.ccc.ari.community.infrastructure.like.entity.AlbumLikeJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class AlbumRepositoryImpl implements AlbumLikeRepository {

    private final AlbumLikeJpaRepository albumLikeJpaRepository;

    @Override
    public void saveAlbumLike(AlbumLike albumLike) {
        AlbumLikeJpaEntity entity = AlbumLikeJpaEntity.fromDomain(albumLike);
        albumLikeJpaRepository.save(entity);
    }

    @Override
    public Optional<AlbumLike> findByAlbumIdAndMemberId(Integer albumId, Integer memberId) {
        return albumLikeJpaRepository.findByAlbumIdAndMemberId(albumId, memberId)
                .map(AlbumLikeJpaEntity::toDomain);
    }
}
