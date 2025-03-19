package com.ccc.ari.music.ui;

import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.music.application.serviceImpl.MusicServiceImpl;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/albums")
@RequiredArgsConstructor
@Slf4j
public class MusicController {

    private final MusicServiceImpl musicService;

    // 음원 재생
    @PostMapping("/{albumId}/tracks/{trackId}")
    public ApiUtils.ApiResponse<TrackPlayResponse> trackPlay(
            @PathVariable Integer albumId,
            @PathVariable Integer trackId) {

        return ApiUtils.success(musicService.trackPlay(TrackPlayCommand.builder()
                .albumId(albumId)
                .trackId(trackId)
                .build()));
    }

}
