package com.ccc.ari.music.application.service.integration;

import com.ccc.ari.global.event.StreamingEvent;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.client.GenreClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Slf4j
@Component
@RequiredArgsConstructor
public class TrackPlayService {

    private final MemberClient memberClient;
    private final TrackClient trackClient;
    private final AlbumClient  albumClient;
    private final ApplicationEventPublisher eventPublisher;
    private final GenreClient genreClient;

    @Transactional
    public TrackPlayResponse trackPlay(TrackPlayCommand trackPlayCommand) {

        TrackDto track = trackClient.getTrackByAlbumIdAndTrackId(trackPlayCommand.getAlbumId(),trackPlayCommand.getTrackId());
        AlbumDto album = albumClient.getAlbumById(trackPlayCommand.getAlbumId());
        GenreDto genre = genreClient.getGenre(album.getGenreName());

        log.info("Track play command: " + track.getTrackId());

        StreamingEvent event = StreamingEvent.builder()
                .memberId(trackPlayCommand.getMemberId())
                .nickname(trackPlayCommand.getNickname())
                .trackId(track.getTrackId())
                .trackTitle(track.getTitle())
                .artistId(album.getMemberId())
                .artistName(album.getArtist())
                .albumId(album.getAlbumId())
                .albumTitle(album.getTitle())
                .genreId(genre.getGenreId())
                .genreName(genre.getGenreName())
                .timestamp(Instant.now())
                .build();

        log.info("타임스탬프 : {}", event.getTimestamp());
        log.info("트랙 제목 : {}", event.getTrackTitle());

        eventPublisher.publishEvent(event);
        log.info("이벤트가 성공적으로 발행되었습니다: 트랙 이름={}, 닉네임={}", event.getTrackTitle(), event.getNickname());

        return TrackPlayResponse.builder()
                .artist(album.getArtist())
                .coverImageUrl(album.getCoverImageUrl())
                .lyrics(track.getLyrics())
                .tackFileUrl(track.getTrackFileUrl())
                .title(track.getTitle())
                .build();
    }
}
