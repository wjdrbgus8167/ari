package com.ccc.ari.playlist.application.service.integration;

import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.domain.playlisttrack.client.PlaylistTrackClient;
import com.ccc.ari.playlist.ui.response.GetPublicPlaylistResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class GetPublicPlaylistService {

    private final PlaylistClient playlistClient;
    private final MemberClient  memberClient;
    private final PlaylistTrackClient playlistTrackClient;

    // 공개된 플레이리스트 전체 가져오기( 나중에 전체 조회 시나 사용될듯)
    public GetPublicPlaylistResponse getPublicPlaylist(){

        List<Playlist> list = playlistClient.getPublicPlalList(true);

        List<GetPublicPlaylistResponse.PlaylistResponse> publicList= list.stream()
                .map(playlist -> GetPublicPlaylistResponse.PlaylistResponse.builder()
                        .playlistId(playlist.getPlaylistId())
                        .playlistTitle(playlist.getPlayListTitle())
                        .publicYn(playlist.isPublicYn())
                        .trackCount(playlistTrackClient.getTrackCount(playlist.getPlaylistId()))
                        .createdAt(playlist.getCreatedAt())
                        .nickname(memberClient.getNicknameByMemberId(playlist.getMemberId()))
                        .shareCount(playlist.getShareCount())
                        .build())
                .collect(Collectors.toList());

        return GetPublicPlaylistResponse.builder().playlists(publicList).build();

    }
}
