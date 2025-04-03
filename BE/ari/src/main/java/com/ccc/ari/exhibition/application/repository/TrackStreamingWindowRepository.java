package com.ccc.ari.exhibition.application.repository;

import com.ccc.ari.exhibition.domain.entity.TrackStreamingWindow;

import java.util.Map;

/**
 * 트랙 스트리밍 윈도우 리포지토리 인터페이스
 */
public interface TrackStreamingWindowRepository {

    // 전체 윈도우 저장
    void saveAllTracksWindows(Map<Integer, TrackStreamingWindow> windows);

    // 장르별 윈도우 저장
    void saveGenreTracksWindows(Integer genreId, Map<Integer, TrackStreamingWindow> windows);

    // 전체 윈도우 조회
    Map<Integer, TrackStreamingWindow> getAllTracksWindows();

    // 장르별 윈도우 조회
    Map<Integer, TrackStreamingWindow> getGenreTracksWindows(Integer genreId);
}
