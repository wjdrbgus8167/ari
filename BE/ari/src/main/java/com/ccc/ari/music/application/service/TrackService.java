package com.ccc.ari.music.application.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.infrastructure.track.JpaTrackRepository;
import com.ccc.ari.music.mapper.TrackMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TrackService {

    private final JpaTrackRepository jpaTrackRepository;

    public List<TrackDto> getTracksByAlbumId(Integer albumId){
        List<TrackEntity> entities = jpaTrackRepository.findAllByAlbum_AlbumId(albumId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        return entities.stream()
                .map(TrackMapper::toDto)
                .toList();

    }

    public TrackDto getTrackById(Integer trackId){
        TrackEntity entity = jpaTrackRepository.findById(trackId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        return TrackMapper.toDto(entity);
    }
}
