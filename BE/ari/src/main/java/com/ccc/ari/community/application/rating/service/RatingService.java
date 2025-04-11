package com.ccc.ari.community.application.rating.service;

import com.ccc.ari.community.application.rating.commad.CreateAlbumRatingCommand;
import com.ccc.ari.community.application.rating.repository.RatingRepository;
import com.ccc.ari.community.domain.rating.entity.AlbumRating;
import com.ccc.ari.community.domain.rating.service.AlbumRatingCalculator;
import com.ccc.ari.community.domain.rating.vo.Rating;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
@Slf4j
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;

    // 앨범 평점 등록
    public void creatRating(CreateAlbumRatingCommand command) {

        // 만약 평점이 0이다-> 평점 삭제
        if (command.getRating().compareTo(BigDecimal.ZERO) == 0) {
            ratingRepository.deleteByMemberIdAndAlbumId(command.getMemberId(), command.getAlbumId());
            return;
        }

        Rating rating = new Rating(command.getRating());
        AlbumRating albumRating = AlbumRating.builder()
                .albumId(command.getAlbumId())
                .rating(rating)
                .updatedAt(LocalDateTime.now())
                .memberId(command.getMemberId())
                .build();

        ratingRepository.saveOrUpdateRating(albumRating);
    }

    public BigDecimal getRating(Integer albumId) {

        BigDecimal albumRatingAvg = AlbumRatingCalculator.calculateAverage(ratingRepository.findAllByAlbumId(albumId));

        return albumRatingAvg;
    }

    public void deleteRating(Integer memberId, Integer albumId) {

        ratingRepository.deleteByMemberIdAndAlbumId(memberId, albumId);
    }

    public AlbumRating findMyRating(Integer memberId,Integer albumId){

        AlbumRating rating =  ratingRepository.findByMemberIdAndAlbumId(memberId,albumId)
                .orElseThrow(()->new ApiException(ErrorCode.ALBUM_RATING_NOT_FOUND));

        return rating;
    }
}
