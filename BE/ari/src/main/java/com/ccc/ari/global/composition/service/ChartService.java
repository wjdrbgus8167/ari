package com.ccc.ari.global.composition.service;

import com.ccc.ari.chart.domain.client.ChartClient;
import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.domain.vo.ChartEntry;
import com.ccc.ari.global.composition.response.ChartResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChartService {

    private final ChartClient chartClient;
    private final TrackClient trackClient;
    private final MemberClient memberClient;
    private final AlbumClient albumClient;

    public ChartResponse getAllChart() {
        Chart chart = chartClient.getLatestAllChart()
                .orElseThrow(() -> new ApiException(ErrorCode.CHART_NOT_FOUND));

        return buildChartResponse(chart);
    }

    public ChartResponse getGenreChart(Integer genreId) {
        Chart chart = chartClient.getLatestGenreChart(genreId)
                .orElseThrow(() -> new ApiException(ErrorCode.CHART_NOT_FOUND));

        return buildChartResponse(chart);
    }

    private ChartResponse buildChartResponse(Chart chart) {
        List<ChartEntry> entries = chart.getEntries();

        List<ChartResponse.ChartItemDto> chartItems = entries.stream()
                .map(entry -> {
                    Integer trackId = entry.getTrackId();

                    // 앨범, 트랙, 회원 정보 조회
                    TrackDto track = trackClient.getTrackById(trackId);
                    AlbumDto album = albumClient.getAlbumById(track.getAlbumId());
                    String artistName = memberClient.getNicknameByMemberId(album.getMemberId());
                    String trackTitle = track.getTitle();
                    String coverImageUrl = album.getCoverImageUrl();

                    return ChartResponse.ChartItemDto.builder()
                            .trackId(trackId)
                            .trackTitle(trackTitle)
                            .artist(artistName)
                            .coverImageUrl(coverImageUrl)
                            .rank(entry.getRank())
                            .build();
                })
                .toList();

        return ChartResponse.builder()
                .charts(chartItems)
                .build();
    }
}
