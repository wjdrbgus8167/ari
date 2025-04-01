package com.ccc.ari.music.domain.album.client;

import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;

public interface AlbumClient {
    AlbumDto getAlbumById(Integer albumId);
    AlbumEntity savedAlbum(AlbumEntity albumEntity);
}
