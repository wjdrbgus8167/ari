
package com.ccc.ari.global.composition.service.mypage;
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

    public GetMyTrackListResponse getMyTrackList(Integer memberId){

        // 아티스트 앨범 조회
        List<AlbumDto> albumDtoList = albumClient.getAllAlbumsByMember(memberId);

        // 앨범 ID로 트랙 전체 조회
        List<TrackDto> trackDtoList = albumDtoList.stream()
                .flatMap(album -> trackClient.getTracksByAlbumId(album.getAlbumId()).stream())
                .toList();

        // 응답 트랙
        List<GetMyTrackListResponse.MyTrack> myTrackList =new ArrayList<>();

      /*
        아티스트 Id로 트랙에 스트리밍 데이터 가져오기
       */
        myTrackList = trackDtoList.stream()
                .map(track -> {

                    // 앨범의 coverImageUrl 가져오기 (albumId로부터 AlbumDto 찾기)
                    String coverImageUrl = albumDtoList.stream()
                            .filter(album -> album.getAlbumId().equals(track.getAlbumId()))
                            .findFirst()
                            .map(AlbumDto::getCoverImageUrl)
                            .orElse(null);

                    return GetMyTrackListResponse.MyTrack.builder()
                            .trackTitle(track.getTitle())
                            .coverImageUrl(coverImageUrl)
                            .monthlyStreamingCount(1)
                            .totalStreamingCount(1)
                            .build();
                })
                .toList();



        return GetMyTrackListResponse.builder().tracks(myTrackList).build();
    }
}