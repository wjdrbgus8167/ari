package com.ccc.ari.community.infrastructure.like.repository;

import com.ccc.ari.community.application.like.repository.LikeRepository;
import com.ccc.ari.community.domain.like.entity.Like;
import com.ccc.ari.community.infrastructure.like.entity.AlbumLikeJpaEntity;
import com.ccc.ari.community.infrastructure.like.entity.TrackLikeJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class AlbumRepositoryImpl implements LikeRepository {

    private final AlbumLikeJpaRepository albumLikeJpaRepository;
    private final TrackLikeJpaRepository trackLikeJpaRepository;

    @Override
    public void saveAlbumLike(Like like) {
        AlbumLikeJpaEntity entity = AlbumLikeJpaEntity.fromDomain(like);
        albumLikeJpaRepository.save(entity);
    }

    @Override
    public void saveTrackLike(Like like) {
        TrackLikeJpaEntity entity = TrackLikeJpaEntity.fromDomain(like);
        trackLikeJpaRepository.save(entity);
    }

    @Override
    public Optional<Like> findByAlbumIdAndMemberId(Integer albumId, Integer memberId) {
        return albumLikeJpaRepository.findByAlbumIdAndMemberId(albumId, memberId)
                .map(AlbumLikeJpaEntity::toDomain);
    }

    @Override
    public Optional<Like> findByTrackIdAndMemberId(Integer trackId, Integer memberId) {
        return trackLikeJpaRepository.findByTrackIdAndMemberId(trackId, memberId)
                .map(TrackLikeJpaEntity::toDomain);
    }
}
