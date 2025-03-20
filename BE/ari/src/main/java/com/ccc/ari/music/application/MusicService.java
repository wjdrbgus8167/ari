package com.ccc.ari.music.application;

import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.music.ui.response.TrackPlayResponse;

public interface MusicService {

    TrackPlayResponse trackPlay(TrackPlayCommand trackPlayCommand);
}
