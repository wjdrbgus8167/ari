package com.ccc.ari.playlist.application.service.integration;

import com.ccc.ari.playlist.application.command.DeletePlaylistCommand;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.domain.sharedplaylist.client.SharedPlaylistClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class DeletePlaylistService {

    private final PlaylistClient playlistClient;
    private final SharedPlaylistClient sharedPlaylistClient;
    @Transactional
    public void deletePlaylist(DeletePlaylistCommand command) {

        // 플레이리스트 먼저 조회
        Playlist playlist = playlistClient.getPlaylistById(command.getPlaylistId());

        // 사용자가 퍼왔던 플레이리스트를 먼저 조회.
        // 이유는 현재 플레이리시트 목록 조회의 경우 사용자가 공개된 플레이리스트를 SharedPlaylist를 통해 참조하여 가져오는 방식
        // 따라서 자신의 플레이리스트 목록을 조회했을 때의 플레이리스트 id를 받아 먼저 이 플레이리스트가 퍼온 플레이리스트인지 확인
        // 만약 퍼온 플레이리스트라면 SharedPlaylist에서 삭제(int 값은 그럼 1), 아니라면 내가 직접 만든 플레이리스트이므로
        int deletedSharedPlaylist =sharedPlaylistClient.deleteSharedPlaylistByMemberIdAndPlaylistId(command.getMemberId(),command.getPlaylistId());

        // 여기서 삭제
        if(deletedSharedPlaylist==0){
            playlistClient.deletePlaylist(playlist.getPlaylistId());
        }

    }
}
