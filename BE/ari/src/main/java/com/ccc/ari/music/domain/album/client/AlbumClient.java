package com.ccc.ari.music.domain.album.client;

import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;

import java.util.List;

public interface AlbumClient {
    AlbumDto getAlbumById(Integer albumId);
    AlbumEntity savedAlbum(AlbumEntity albumEntity);
    List<AlbumDto> getAllAlbumsByMember(Integer memberId);
}
