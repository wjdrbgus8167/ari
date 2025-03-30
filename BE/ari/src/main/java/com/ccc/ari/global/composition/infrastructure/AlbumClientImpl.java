package com.ccc.ari.global.composition.infrastructure;

import com.ccc.ari.music.application.service.AlbumService;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AlbumClientImpl implements AlbumClient {

    private final AlbumService albumService;

    @Override
    public AlbumDto getAlbumById(Integer albumId) {
        return albumService.getAlbumById(albumId);

    }
}
