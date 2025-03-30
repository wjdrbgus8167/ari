package com.ccc.ari.music.application.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.infrastructure.album.JpaAlbumRepository;
import com.ccc.ari.music.mapper.AlbumMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AlbumService {

    private final JpaAlbumRepository jpaAlbumRepository;

    public AlbumDto getAlbumById(Integer albumId) {
        AlbumEntity entity = jpaAlbumRepository.findById(albumId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        return AlbumMapper.toDto(entity);
    }
}
