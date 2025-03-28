package com.ccc.ari.music.application.serviceImpl;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.infrastructure.S3Service;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.infrastructure.JpaMemberRepository;
import com.ccc.ari.music.application.MusicService;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.global.event.StreamingEvent;
import com.ccc.ari.music.application.command.UploadAlbumCommand;
import com.ccc.ari.music.domain.genre.GenreEntity;
import com.ccc.ari.music.domain.service.UploadAlbumService;
import com.ccc.ari.music.event.producer.KafkaProducerService;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.infrastructure.album.JpaAlbumRepository;
import com.ccc.ari.music.infrastructure.genre.JpaGenreRepository;
import com.ccc.ari.music.infrastructure.track.JpaTrackRepository;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MusicServiceImpl implements MusicService {

    private final JpaTrackRepository jpaTrackRepository;
    private final JpaAlbumRepository jpaAlbumRepository;
    private final UploadAlbumService uploadAlbumService;
    private final ApplicationEventPublisher eventPublisher;
    private final JpaMemberRepository jpaMemberRepository;
    private final JpaGenreRepository jpaGenreRepository;

    @Transactional
    @Override
    public TrackPlayResponse trackPlay(TrackPlayCommand trackPlayCommand) {

        TrackEntity track = jpaTrackRepository
                .findByAlbum_AlbumIdAndTrackId(trackPlayCommand.getAlbumId(), trackPlayCommand.getTrackId())
                .orElseThrow(() -> new ApiException(ErrorCode.MUSIC_FILE_NOT_FOUND));

        log.info("Track play command: " + track.getTrackId());

        StreamingEvent event = StreamingEvent.builder()
                .memberId(trackPlayCommand.getMemberId())
                .nickname(trackPlayCommand.getNickname())
                .trackId(track.getTrackId())
                .trackTitle(track.getTrackTitle())
                .artistId(track.getAlbum().getMember().getMemberId())
                .artistName(track.getAlbum().getMember().getNickname())
                .albumId(track.getAlbum().getAlbumId())
                .albumTitle(track.getAlbum().getAlbumTitle())
                .genreId(track.getAlbum().getGenre().getGenreId())
                .genreName(track.getAlbum().getGenre().getGenreName())
                .timestamp(Instant.now())
                .build();

        log.info("타임스탬프 : {}", event.getTimestamp());
        log.info("트랙 제목 : {}", event.getTrackTitle());

        eventPublisher.publishEvent(event);
        log.info("이벤트가 성공적으로 발행되었습니다: 트랙 이름={}, 닉네임={}", event.getTrackTitle(), event.getNickname());

        return TrackPlayResponse.builder()
                .artist(track.getAlbum().getMember().getNickname())
                .coverImageUrl(track.getAlbum().getCoverImageUrl())
                .lyrics(track.getLyrics())
                .tackFileUrl(track.getTrackFileUrl())
                .title(track.getTrackTitle())
                .build();
    }

    @Transactional
    @Override
    public void uploadAlbum(UploadAlbumCommand command){

        String coverUrl = uploadAlbumService.uploadCoverImage(command.getCoverImage());

        MemberEntity member = jpaMemberRepository.findByMemberId(command.getMemberId())
                .orElseThrow(()-> new ApiException(ErrorCode.MEMBER_NOT_FOUND));

        GenreEntity genre = GenreEntity.builder()
                .genreName(command.getGenreName())
                .build();

        GenreEntity savedGenre =jpaGenreRepository.save(genre);

        // 앨범 메타데이터 DB 저장
        // 추후 Security 인증인가 구현되는데로 memberId 추가 예정
        AlbumEntity album = AlbumEntity.builder()
                .albumTitle(command.getAlbumTitle())
                .description(command.getDescription())
                .coverImageUrl(coverUrl)
                .albumLikeCount(0)
                .releasedAt(LocalDateTime.now())
                .genre(savedGenre)
                .member(member)
                .build();

        AlbumEntity savedAlbum = jpaAlbumRepository.save(album);

        // 트랙 처리
        List<TrackEntity> tracks = command.getTracks().stream()
                .map(trackCommand -> {
                    try {

                        String trackUrl = uploadAlbumService.uploadTrack(trackCommand.getTrackFile());

                        log.info("S3에 업로드 여부:{}", trackUrl);

                        // 트랙 메타데이터 DB 저장
                        return TrackEntity.builder()
                                .album(savedAlbum)
                                .trackNumber(trackCommand.getTrackNumber())
                                .trackTitle(trackCommand.getTrackTitle())
                                .composer(trackCommand.getComposer())
                                .lyricist(trackCommand.getLyricist())
                                .lyrics(trackCommand.getLyrics())
                                .trackLikeCount(0)
                                .trackFileUrl(trackUrl)
                                .build();
                    } catch (Exception e) {
                        throw new RuntimeException("트랙 변환 & 업로드 실패: " + trackCommand.getTrackTitle(), e);
                    }
                })
                .collect(Collectors.toList());

        // 트랙 DB 저장
        jpaTrackRepository.saveAll(tracks);

    }
}

