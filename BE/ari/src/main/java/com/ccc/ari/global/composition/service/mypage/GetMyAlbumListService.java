package com.ccc.ari.global.composition.service.mypage;

import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.global.composition.response.mypage.GetMyAlbumListResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class GetMyAlbumListService {

    private final AlbumClient albumClient;
    private final TrackClient trackClient;

    public List<GetMyAlbumListResponse> getAlbumList(Integer memberId, String nickname){

        List<AlbumDto> albumDtoList = albumClient.getAllAlbumsByMember(memberId);

        List<GetMyAlbumListResponse> list= albumDtoList.stream()
                .map(album -> GetMyAlbumListResponse.builder()
                        .albumId(album.getAlbumId())
                        .albumTitle(album.getTitle())
                        .genre(album.getGenreName())
                        .trackCount(trackClient.getTracksByAlbumId(album.getAlbumId()).size())
                        .releasedAt(album.getReleasedAt())
                        .coverImageUrl(album.getCoverImageUrl())
                        .description(album.getDescription())
                        .memberId(memberId)
                        .artist(nickname)
                        .build())
                .collect(Collectors.toList());

        return list;
    }
}
