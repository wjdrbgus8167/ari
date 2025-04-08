package com.ccc.ari.music.infrastructure.repository.album;

import com.ccc.ari.music.domain.album.AlbumEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface JpaAlbumRepository extends JpaRepository<AlbumEntity,Integer> {
    Optional<AlbumEntity> findByAlbumId(Integer albumId);
    List<AlbumEntity> findAllByMember_MemberId(Integer memberId);

    List<AlbumEntity> findTop10ByOrderByReleasedAtDesc();

    List<AlbumEntity> findTop10ByGenre_GenreIdOrderByReleasedAtDesc(Integer genreId);

    // 징르별 TOP5
    List<AlbumEntity> findTop5ByGenre_GenreIdOrderByAlbumLikeCountDesc(Integer genreId);

    //전체에서 앨범 TOP10
    List<AlbumEntity> findTop10ByOrderByAlbumLikeCountDesc();

    Optional<List<AlbumEntity>> findListByMember_MemberId(Integer memberId);

    // 사용자의 앨범인지 획인
    boolean existsByAlbumIdAndMember_MemberId(Integer albumId, Integer memberId);
}
