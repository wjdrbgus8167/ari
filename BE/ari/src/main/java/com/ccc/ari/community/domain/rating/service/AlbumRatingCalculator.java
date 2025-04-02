package com.ccc.ari.community.domain.rating.service;

import com.ccc.ari.community.domain.rating.entity.AlbumRating;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/*
    앨범 평점의 평균을 계산하는 로직
 */
@Service
@RequiredArgsConstructor
public class AlbumRatingCalculator {

    public static BigDecimal calculateAverage(List<AlbumRating> ratings) {

        // 만약 등록된 앨범 평점이 없다면 0.0 return
        if (ratings.isEmpty()) {
            return BigDecimal.ZERO.setScale(1);
        }

        BigDecimal total = ratings.stream()
                .map(e -> e.getRating().getValue())
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return total.divide(BigDecimal.valueOf(ratings.size()), 1, RoundingMode.HALF_UP);
    }
}
