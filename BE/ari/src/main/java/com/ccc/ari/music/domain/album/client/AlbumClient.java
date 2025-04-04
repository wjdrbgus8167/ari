package com.ccc.ari.music.domain.album.client;

import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;

import java.util.List;

public interface AlbumClient {
    AlbumDto getAlbumById(Integer albumId);
    AlbumEntity savedAlbum(AlbumEntity albumEntity);
    List<AlbumDto> getAllAlbumsByMember(Integer memberId);

    // 최신 앨범 TOP10
    List<AlbumEntity> getTop10ByReleasedAt();

    // 장르별 TOP5
    List<AlbumEntity> getTop5GenreAlbum(Integer genreId);

    // 전체 인기 앨범 조회 TOP10
    List<AlbumEntity> getTop10Album();
}
