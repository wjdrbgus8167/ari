package com.ccc.ari.music.domain.track.client;

import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.TrackEntity;

import java.util.List;

public interface TrackClient {
    List<TrackDto> getTracksByAlbumId(Integer albumId);
    TrackDto getTrackById(Integer trackId);
    List<TrackEntity> saveTracks(List<TrackEntity> trackEntities);
    TrackDto getTrackByAlbumIdAndTrackId(Integer albumId, Integer trackId);
    TrackEntity getTrackByTrackId(Integer trackId);

    //트랙 좋아요 증가 감소
    void increaseTrackLikeCount(Integer trackId);
    void decreaseTrackLikeCount(Integer trackId);

    // 트랙 검색
    List<TrackDto> searchTracksByKeyword(String query);

    Integer countTracksByAlbumId(Integer albumId);
}
