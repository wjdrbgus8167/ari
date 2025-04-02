package com.ccc.ari.playlist.application;

import com.ccc.ari.playlist.application.command.*;
import com.ccc.ari.playlist.ui.response.CreatePlaylistResponse;
import com.ccc.ari.playlist.ui.response.GetPlayListResponse;
import com.ccc.ari.playlist.ui.response.GetPlaylistDetailResponse;

public interface PlaylistService {

    CreatePlaylistResponse createPlaylist(CreatePlaylistCommand createPlaylistCommand);
    void addTrack(AddTrackCommand addTrackCommand);
    void deletePlaylistTrack(DeletePlaylistTrackCommand command);
    void deletePlaylist(DeletePlaylistCommand deletePlaylistCommand);
    GetPlayListResponse getPlaylist(GetPlaylistCommand getPlaylistCommand);
    GetPlaylistDetailResponse getPlaylistDetail(GetPlaylistDetailCommand getPlaylistDetailCommand);
    void sharePlaylist(SharePlaylistCommand sharePlaylistCommand);
    void publicPlaylist(PublicPlaylistCommand publicPlaylistCommand);
}
