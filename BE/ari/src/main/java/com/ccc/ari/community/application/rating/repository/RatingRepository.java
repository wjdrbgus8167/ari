package com.ccc.ari.community.application.rating.repository;

import com.ccc.ari.community.domain.rating.entity.AlbumRating;

import java.util.List;
import java.util.Optional;

public interface RatingRepository {

    // 앨범 평점 저장
    /*
       사용자가 등록한 앨범 평점이 존재한다면 새롭게 업데이트,
       첫 앨범 평점 등록이라면 그대로 평점 등록.
     */
    void saveOrUpdateRating(AlbumRating albumRating);

    // 본인이 등록한 앨범 평점 조회
    Optional<AlbumRating> findByMemberIdAndAlbumId(Integer memberId, Integer albumId);

    // 등록된 앨범 평점 조회
    List<AlbumRating> findAllByAlbumId(Integer albumId);

    // 앨범 평점 삭제
    void deleteByMemberIdAndAlbumId(Integer memberId, Integer albumId);

}
