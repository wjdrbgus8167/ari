package com.ccc.ari.global.composition.service.artist;

import com.ccc.ari.global.composition.response.artiis.GetArtistAlbumListResponse;

import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GetArtisAlbumListService {

    private final AlbumClient albumClient;
    private final TrackClient trackClient;

    public List<GetArtistAlbumListResponse> getArtisAlbumListService(Integer memberId){

        List<AlbumDto> albumDtoList = albumClient.getAllAlbumsByMember(memberId);

        List<GetArtistAlbumListResponse> list= albumDtoList.stream()
                .map(album -> GetArtistAlbumListResponse.builder()
                        .albumId(album.getAlbumId())
                        .albumTitle(album.getTitle())
                        .genre(album.getGenreName())
                        .trackCount(trackClient.getTracksByAlbumId(album.getAlbumId()).size())
                        .releasedAt(album.getReleasedAt())
                        .coverImageUrl(album.getCoverImageUrl())
                        .description(album.getDescription())
                        .memberId(memberId)
                        .artist(album.getArtist())
                        .build())
                .collect(Collectors.toList());

        return list;
    }
}
