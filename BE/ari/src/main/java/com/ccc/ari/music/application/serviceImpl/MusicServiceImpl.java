package com.ccc.ari.music.application.serviceImpl;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.music.application.MusicService;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.global.event.StreamingEvent;
import com.ccc.ari.music.event.producer.KafkaProducerService;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.infrastructure.album.JpaAlbumRepository;
import com.ccc.ari.music.infrastructure.track.JpaTrackRepository;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
@Slf4j
public class MusicServiceImpl implements MusicService {

    private final JpaTrackRepository jpaTrackRepository;
    private final JpaAlbumRepository jpaAlbumRepository;
    private final KafkaProducerService kafkaProducerService;

    @Transactional
    @Override
    public TrackPlayResponse trackPlay(TrackPlayCommand trackPlayCommand) {

        TrackEntity track = jpaTrackRepository.findByTrackId(trackPlayCommand.getTrackId())
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        AlbumEntity album = jpaAlbumRepository.findByAlbumId(trackPlayCommand.getAlbumId())
                .orElseThrow(()-> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));


        StreamingEvent event = StreamingEvent.builder()
                .trackId(track.getTrackId())
                .trackTitle(track.getTrackTitle())
                .artist(album.getMember().getNickname())
                .albumId(album.getAlbumId())
                .albumTitle(album.getAlbumTitle())
                .genreId(album.getGenre().getGenreId())
                .genreName(album.getGenre().getGenreName())
                .timestamp(Instant.now())
                .build();

        log.info("트랙 플레이 : {}", event);

        kafkaProducerService.sendStreamingEvent(event);

        return TrackPlayResponse.builder()
                .artist(album.getMember().getNickname())
                .coverImageUrl(album.getCoverImageUrl())
                .lyrics(track.getLyrics())
                .tackFileUrl(track.getTrackFileUrl())
                .title(track.getTrackTitle())
                .build();
    }
}

