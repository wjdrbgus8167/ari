package com.ccc.ari.community.infrastructure.rating.repository;

import com.ccc.ari.community.application.rating.repository.RatingRepository;

import com.ccc.ari.community.domain.rating.entity.AlbumRating;
import com.ccc.ari.community.infrastructure.rating.entity.AlbumRatingJpaEntity;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Component
@Slf4j
@RequiredArgsConstructor
public class AlbumRatingRepositoryImpl implements RatingRepository {

    private final AlbumRatingJpaRepository albumRatingJpaRepository;

    @Override
    public void saveOrUpdateRating(AlbumRating rating) {

        log.info("평점:{}", rating.getAlbumId());

        AlbumRatingJpaEntity entity = albumRatingJpaRepository
                .findByMemberIdAndAlbumId(rating.getMemberId(), rating.getAlbumId())
                .map(e -> {
                    e.updateRating(rating.getRating().getValue());
                    e.updateUpdatedAt(LocalDateTime.now());
                    return e;
                })
                .orElseGet(() -> AlbumRatingJpaEntity.toEntity(rating));

        albumRatingJpaRepository.save(entity);
    }

    @Override
    public Optional<AlbumRating> findByMemberIdAndAlbumId(Integer memberId, Integer albumId) {
        return albumRatingJpaRepository.findByMemberIdAndAlbumId(memberId, albumId)
                .map(AlbumRatingJpaEntity::toDomain);
    }

    @Override
    public List<AlbumRating> findAllByAlbumId(Integer albumId) {
        return albumRatingJpaRepository.findAllByAlbumId(albumId)
                .stream()
                .map(AlbumRatingJpaEntity::toDomain)
                .toList();
    }

    @Override
    @Transactional
    public void deleteByMemberIdAndAlbumId(Integer memberId, Integer albumId) {

        AlbumRatingJpaEntity entity = albumRatingJpaRepository.findByMemberIdAndAlbumId(memberId, albumId)
                .orElseThrow(()-> new ApiException(ErrorCode.ALBUM_RATING_NOT_FOUND));

        albumRatingJpaRepository.deleteByMemberIdAndAlbumId(memberId,albumId);

    }

}
