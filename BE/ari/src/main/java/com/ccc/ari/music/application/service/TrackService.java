package com.ccc.ari.music.application.service;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.infrastructure.repository.track.JpaTrackRepository;
import com.ccc.ari.music.mapper.TrackMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional(readOnly = true)
    public TrackDto getTrackById(Integer trackId){
        TrackEntity entity = jpaTrackRepository.findById(trackId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        return TrackMapper.toDto(entity);
    }

    public List<TrackEntity> saveTracks(List<TrackEntity> entities){
        List<TrackEntity> tracks = jpaTrackRepository.saveAll(entities);

        return tracks;

    }

    public TrackDto getTrackByAlbumIdAndTrackId(Integer albumId, Integer trackId){
        TrackEntity trackEntity = jpaTrackRepository.findByAlbum_AlbumIdAndTrackId(albumId, trackId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        return TrackMapper.toDto(trackEntity);
    }

    public TrackEntity getTrackByTrackId(Integer trackId){

        return jpaTrackRepository.findById(trackId).orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));
    }

    public void increaseTrackLikeCount(Integer trackId) {
        TrackEntity track = jpaTrackRepository.findById(trackId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));
        track.increaseLikeCount();
    }

    public void decreaseTrackLikeCount(Integer trackId) {
        TrackEntity track = jpaTrackRepository.findById(trackId)
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));
        track.decreaseLikeCount();
    }

    @Transactional(readOnly = true)
    public List<TrackDto> searchTracksByKeyword(String query) {
        List<TrackEntity> entities = jpaTrackRepository.findByTrackTitleContaining(query);

        return entities.stream()
                .map(TrackMapper::toDto)
                .toList();
    }

    public Integer countTracksByAlbumId(Integer albumId) {
        return jpaTrackRepository.countAllByAlbumId(albumId);
    }
}
