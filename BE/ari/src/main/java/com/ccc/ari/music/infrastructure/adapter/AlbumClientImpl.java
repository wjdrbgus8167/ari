package com.ccc.ari.music.infrastructure.adapter;

import com.ccc.ari.music.application.service.AlbumService;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class AlbumClientImpl implements AlbumClient {

    private final AlbumService albumService;

    @Override
    public AlbumDto getAlbumById(Integer albumId) {
        return albumService.getAlbumById(albumId);

    }

    @Override
    public AlbumEntity savedAlbum(AlbumEntity albumEntity) {
        return albumService.saveAlbum(albumEntity);
    }

    @Override
    public List<AlbumDto> getAllAlbumsByMember(Integer memberId) {
        return albumService.getAllAlbumsByMember(memberId);
    }

    @Override
    public Optional<List<AlbumEntity>> getAllAlbums(Integer memberId) {
        return albumService.getAllAlbums(memberId);
    }

    // 가장 최신 앨범 10개 조회
    @Override
    public List<AlbumEntity> getTop10ByReleasedAt() {

        return albumService.getTop10ByReleasedAt();
    }

    // 장르별 최신 앨범 10개 조회
    @Override
    public List<AlbumEntity> getTop10ByReleasedAtAndGenre(Integer genreId) {
        return albumService.getTop10NewAlbumsByGenre(genreId);
    }

    // 장르별 인기 앨범 TOP5
    @Override
    public List<AlbumEntity> getTop5GenreAlbum(Integer genreId) {
        return albumService.getTop5AlbumsByEachGenre(genreId);
    }

    // 전체 인기앨범 TOP10
    @Override
    public List<AlbumEntity> getTop10Album() {
        return albumService.getTop10Album();
    }

    @Override
    public void increaseAlbumLikeCount(Integer albumId) {
        albumService.increaseAlbumLikeCount(albumId);
    }

    @Override
    public void decreaseAlbumLikeCount(Integer albumId) {
        albumService.decreaseAlbumLikeCount(albumId);
    }

    @Override
    public boolean isMyAlbum(Integer albumId,Integer memberId) {
        return albumService.existsByIdAndMemberId(albumId,memberId);
    }

}
