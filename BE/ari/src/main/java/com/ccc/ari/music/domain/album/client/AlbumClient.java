package com.ccc.ari.music.domain.album.client;

import com.ccc.ari.music.domain.album.AlbumDto;

public interface AlbumClient {
    AlbumDto getAlbumById(Integer albumId);
}
