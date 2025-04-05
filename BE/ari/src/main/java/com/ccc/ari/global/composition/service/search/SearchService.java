package com.ccc.ari.global.composition.service.search;

import com.ccc.ari.global.composition.response.search.SearchResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final MemberClient memberClient;
    private final TrackClient trackClient;
    private final AlbumClient albumClient;

    public SearchResponse search(String query) {
        // 1. 검색 결과를 가져옵니다.
        List<MemberDto> members = memberClient.searchMembersByKeyword(query);
        List<TrackDto> tracks = trackClient.searchTracksByKeyword(query);

        // 2. DTO를 응답 객체로 변환합니다.
        List<SearchResponse.ArtistItem> artistItems = members.stream()
                .map(member -> SearchResponse.ArtistItem.builder()
                        .memberId(member.getMemberId())
                        .nickname(member.getNickname())
                        .profileImageUrl(member.getProfileImageUrl())
                        .build())
                .toList();

        List<SearchResponse.TrackItem> trackItems = tracks.stream()
                .map(track -> {
                    AlbumDto album = albumClient.getAlbumById(track.getAlbumId());

                    return SearchResponse.TrackItem.builder()
                            .trackId(track.getTrackId())
                            .trackTitle(track.getTitle())
                            .artist(album.getArtist())
                            .coverImageUrl(album.getCoverImageUrl())
                            .build();
                })
                .toList();

        return SearchResponse.builder()
                .artists(artistItems)
                .tracks(trackItems)
                .build();
    }
}
