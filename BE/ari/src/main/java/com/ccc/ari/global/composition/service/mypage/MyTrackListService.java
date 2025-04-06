
package com.ccc.ari.global.composition.service.mypage;
import com.ccc.ari.aggregation.ui.client.StreamingCountClient;
import com.ccc.ari.aggregation.ui.response.GetArtistTrackCountListResponse;
import com.ccc.ari.aggregation.ui.response.TrackCountResult;
import com.ccc.ari.global.composition.response.mypage.GetMyTrackListResponse;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;


@Service
@RequiredArgsConstructor
public class MyTrackListService {

    private final TrackClient trackClient;
    private final AlbumClient albumClient;
    private final StreamingCountClient streamingCountClient;

    public GetMyTrackListResponse getMyTrackList(Integer memberId){

        // 아티스트 앨범 조회
        List<AlbumDto> albumDtoList = albumClient.getAllAlbumsByMember(memberId);

        // 앨범 ID로 트랙 전체 조회
        List<TrackDto> trackDtoList = albumDtoList.stream()
                .flatMap(album -> trackClient.getTracksByAlbumId(album.getAlbumId()).stream())
                .toList();

        // 아티스트 Id로 트랙에 스트리밍 데이터 가져오기
        GetArtistTrackCountListResponse streamingCount = streamingCountClient.getArtistTrackCounts(memberId);

        // 응답 트랙 생성
        List<GetMyTrackListResponse.MyTrack> myTrackList = trackDtoList.stream()
                .map(track -> {

                    // 앨범 coverImageUrl 찾기
                    String coverImageUrl = albumDtoList.stream()
                            .filter(album -> album.getAlbumId().equals(track.getAlbumId()))
                            .findFirst()
                            .map(AlbumDto::getCoverImageUrl)
                            .orElse(null);

                    // 트랙에 해당하는 스트리밍 카운트 찾기 (없으면 0으로 대체)
                    TrackCountResult matchedCount = streamingCount.getTrackCountList().stream()
                            .filter(trackCount -> trackCount.getTrackId().equals(track.getTrackId()))
                            .findFirst()
                            .orElse(TrackCountResult.builder()
                                    .trackId(track.getTrackId())
                                    .totalCount(0)
                                    .monthCount(0)
                                    .build());

                    return GetMyTrackListResponse.MyTrack.builder()
                            .trackTitle(track.getTitle())
                            .coverImageUrl(coverImageUrl)
                            .totalStreamingCount(matchedCount.getTotalCount())
                            .monthlyStreamingCount(matchedCount.getMonthCount())
                            .build();
                })
                .toList();

        return GetMyTrackListResponse.builder()
                .tracks(myTrackList)
                .build();
    }
}