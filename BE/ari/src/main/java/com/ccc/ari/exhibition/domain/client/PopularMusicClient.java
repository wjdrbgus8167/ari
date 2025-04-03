package com.ccc.ari.exhibition.domain.client;

import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;

import java.util.Optional;

public interface PopularMusicClient {

    // 최신 전체 인기 앨범 조회
    Optional<PopularAlbum> getLatestPopularAlbum(Integer genreId);

    // 최신 전체 인기 트랙 조회
    Optional<PopularTrack> getLatestPopularTrack(Integer genreId);
}
