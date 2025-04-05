package com.ccc.ari.global.composition.service.artist;

import com.ccc.ari.global.composition.response.artist.GetArtistPublicPlaylistResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GetArtistPublicPlaylistService {

    private final PlaylistClient playlistClient;
    private final MemberClient memberClient;

    public GetArtistPublicPlaylistResponse getArtistPublicPlaylist(Integer memberId){

        String artist= memberClient.getNicknameByMemberId(memberId);

        List<PlaylistEntity> list  = playlistClient.getArtistPublicPlaylist(memberId);


        // 직접 만든 플레이리스트 → PlaylistResponse로 변환
        List<GetArtistPublicPlaylistResponse.ArtistPublicPlaylistResponse> myPlaylist = list.stream()
                .map(playlist -> GetArtistPublicPlaylistResponse.ArtistPublicPlaylistResponse.builder()
                        .playlistId(playlist.getPlaylistId())
                        .playlistTitle(playlist.getPlaylistTitle())
                        .publicYn(playlist.isPublicYn())
                        .trackCount(playlist.getTracks().size())
                        .coverImageUrl(
                                !playlist.getTracks().isEmpty()
                                        ? playlist.getTracks().get(0).getTrack().getAlbum().getCoverImageUrl()
                                        : null
                        )
                        .artist(
                                !playlist.getTracks().isEmpty()
                                        ? playlist.getTracks().get(0).getTrack().getAlbum().getMember().getNickname()
                                        : null
                        )
                        .build()).toList();

        return GetArtistPublicPlaylistResponse.builder()
                .artist(artist)
                .playlists(myPlaylist)
                .build();
    }

}
