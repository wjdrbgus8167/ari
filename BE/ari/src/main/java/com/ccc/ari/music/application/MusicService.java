package com.ccc.ari.music.application;

import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.music.application.command.UploadAlbumCommand;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import com.ccc.ari.music.ui.response.UploadAlbumResponse;

public interface MusicService {

    TrackPlayResponse trackPlay(TrackPlayCommand trackPlayCommand);
    UploadAlbumResponse uploadAlbum(UploadAlbumCommand uploadAlbumCommand);
}
