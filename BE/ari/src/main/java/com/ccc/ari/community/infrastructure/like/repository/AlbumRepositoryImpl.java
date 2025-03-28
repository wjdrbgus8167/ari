package com.ccc.ari.community.infrastructure.like.repository;

import com.ccc.ari.community.application.like.repository.LikeRepository;
import com.ccc.ari.community.domain.like.LikeType;
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
    public void saveLike(Like like, LikeType type) {
        switch (type) {
            case ALBUM:
                AlbumLikeJpaEntity albumEntity = AlbumLikeJpaEntity.fromDomain(like);
                albumLikeJpaRepository.save(albumEntity);
                break;
            case TRACK:
                TrackLikeJpaEntity trackEntity = TrackLikeJpaEntity.fromDomain(like);
                trackLikeJpaRepository.save(trackEntity);
                break;
        }
    }

    @Override
    public Optional<Like> findByTargetAndMember(Integer targetId, Integer memberId, LikeType type) {
        return switch (type) {
            case ALBUM -> albumLikeJpaRepository.findByAlbumIdAndMemberId(targetId, memberId)
                    .map(AlbumLikeJpaEntity::toDomain);
            case TRACK -> trackLikeJpaRepository.findByTrackIdAndMemberId(targetId, memberId)
                    .map(TrackLikeJpaEntity::toDomain);
        };
    }
}
