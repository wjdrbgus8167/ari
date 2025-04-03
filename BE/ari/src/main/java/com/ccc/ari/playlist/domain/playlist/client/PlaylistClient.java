package com.ccc.ari.playlist.domain.playlist.client;

import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;

import java.util.List;

public interface PlaylistClient {

    Playlist getPlaylistById(Integer playlistId);
    List<PlaylistEntity> getPlayListAllByMemberId(Integer memberId);
    List<Playlist> getPublicPlalList(boolean publicYn);
    void savePlaylist(PlaylistEntity playlist);
    void deletePlaylist(Integer playlistId);
    PlaylistEntity getPlaylistDetailById(Integer playlistId);
}
