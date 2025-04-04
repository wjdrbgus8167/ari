package com.ccc.ari.exhibition.domain.client;

import com.ccc.ari.exhibition.domain.entity.NewAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularPlaylist;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;

import javax.swing.text.html.Option;
import java.util.Optional;

public interface PopularItemClient {

    // 최신 인기 앨범 조회
    Optional<PopularAlbum> getLatestPopularAlbum(Integer genreId);

    // 최신 인기 트랙 조회
    Optional<PopularTrack> getLatestPopularTrack(Integer genreId);

    // 최신 인기 플레이리스트 조회
    Optional<PopularPlaylist> getLatestPopularPlaylist();

    // 최신 앨범 조회
    Optional<NewAlbum> getNewAlbum(Integer genreId);
}
