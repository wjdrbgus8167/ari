package com.ccc.ari.music.infrastructure.adapter;

import com.ccc.ari.music.application.service.AlbumService;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

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

    // 가장 최신 앨범 10개 조회
    @Override
    public List<AlbumEntity> getTop10ByReleasedAt() {

        return albumService.getTop10ByReleasedAt();
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

}
