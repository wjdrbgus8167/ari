package com.ccc.ari.music.application.service.integration;

import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.member.mapper.MemberMapper;
import com.ccc.ari.music.application.command.UploadAlbumCommand;
import com.ccc.ari.music.domain.album.AlbumEntity;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.genre.GenreDto;
import com.ccc.ari.music.domain.genre.client.GenreClient;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.music.domain.track.client.TrackClient;
import com.ccc.ari.music.infrastructure.adapter.S3ClientImpl;
import com.ccc.ari.music.mapper.GenreMapper;
import com.ccc.ari.music.ui.response.UploadAlbumResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class UploadAlbumService {

    private final MemberClient memberClient;
    private final GenreClient genreClient;
    private final S3ClientImpl s3Client;
    private final AlbumClient albumClient;
    private final TrackClient trackClient;

    public UploadAlbumResponse uploadAlbum(UploadAlbumCommand command){

        String coverUrl = s3Client.uploadCoverImage(command.getCoverImage());

        MemberDto member  = memberClient.getMemberByMemberId(command.getMemberId());

        GenreDto genre = genreClient.getGenre(command.getGenreName());

        // 앨범 메타데이터 DB 저장

        AlbumEntity album = AlbumEntity.builder()
                .albumTitle(command.getAlbumTitle())
                .description(command.getDescription())
                .coverImageUrl(coverUrl)
                .albumLikeCount(0)
                .releasedAt(LocalDateTime.now())
                .genre(GenreMapper.toEntity(genre))
                .member(MemberMapper.toEntity(member))
                .build();

        AlbumEntity savedAlbum = albumClient.savedAlbum(album);

        // 트랙 처리
        List<TrackEntity> tracks = command.getTracks().stream()
                .map(trackCommand -> {
                    try {

                        String trackUrl = s3Client.uploadTrack(trackCommand.getTrackFile());

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
        List<TrackEntity> savedTracks =trackClient.saveTracks(tracks);

        // 트랙 응답 변환
        List<UploadAlbumResponse.TrackResponse> trackResponses = savedTracks.stream()
                .map(track -> UploadAlbumResponse.TrackResponse.builder()
                        .trackId(track.getTrackId())
                        .trackTitle(track.getTrackTitle())
                        .trackNumber(track.getTrackNumber())
                        .composer(track.getComposer())
                        .lyricist(track.getLyricist())
                        .lyrics(track.getLyrics())
                        .trackFileUrl(track.getTrackFileUrl())
                        .build())
                .collect(Collectors.toList());

        // 최종 응답 DTO 생성
        UploadAlbumResponse response = UploadAlbumResponse.builder()
                .albumId(savedAlbum.getAlbumId())
                .albumTitle(savedAlbum.getAlbumTitle())
                .coverImageUrl(savedAlbum.getCoverImageUrl())
                .description(savedAlbum.getDescription())
                .releasedAt(savedAlbum.getReleasedAt())
                .genre(savedAlbum.getGenre().getGenreName())
                .nickname(savedAlbum.getMember().getNickname())
                .memberId(savedAlbum.getMember().getMemberId())
                .trackCount(savedTracks.size())
                .tracks(trackResponses)
                .build();

        return response;
    }

}