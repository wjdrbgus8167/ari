package com.ccc.ari.global.composition.service.mainpage;

import com.ccc.ari.exhibition.domain.client.PopularItemClient;
import com.ccc.ari.exhibition.domain.entity.NewAlbum;
import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.ccc.ari.global.composition.response.mainpage.NewAlbumResponse;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NewAlbumService {

    private final PopularItemClient popularItemClient;
    private final AlbumClient albumClient;
    private final TrackClient trackClient;
    private final MemberClient memberClient;

    public NewAlbumResponse getAllNewAlbums() {
        NewAlbum newAlbum = popularItemClient.getNewAlbum(null)
                .orElseThrow(() -> new ApiException(ErrorCode.NEW_ALL_ALBUM_NOT_FOUND));

        return buildNewAlbumResponse(newAlbum);
    }

    public NewAlbumResponse getGenreNewAlbums(Integer genreId) {
        NewAlbum newAlbum = popularItemClient.getNewAlbum(genreId)
                .orElseThrow(() -> new ApiException(ErrorCode.NEW_GENRE_ALBUM_NOT_FOUND));

        return buildNewAlbumResponse(newAlbum);
    }

    private NewAlbumResponse buildNewAlbumResponse(NewAlbum newAlbum) {
        List<NewAlbumResponse.NewAlbumItem> albumItems = new ArrayList<>();

        // 각 앨범의 상세 정보를 순차적으로 조회
        for (AlbumEntry entry : newAlbum.getEntries()) {
            Integer albumId = entry.getAlbumId();

            AlbumDto albumDto = albumClient.getAlbumById(albumId);
            List<TrackDto> tracks = trackClient.getTracksByAlbumId(albumId);
            String artistName = memberClient.getNicknameByMemberId(albumDto.getMemberId());

            // 트랙 목록 구성
            List<NewAlbumResponse.TrackItem> trackItems = new ArrayList<>();
            for (TrackDto track : tracks) {
                trackItems.add(NewAlbumResponse.TrackItem.builder()
                        .trackId(track.getTrackId())
                        .trackTitle(track.getTitle())
                        .build());
            }

            // 앨범 항목 추가
            albumItems.add(NewAlbumResponse.NewAlbumItem.builder()
                    .albumId(albumId)
                    .albumTitle(albumDto.getTitle())
                    .artist(artistName)
                    .coverImageUrl(albumDto.getCoverImageUrl())
                    .trackCount(tracks.size())
                    .tracks(trackItems)
                    .build());
        }

        return NewAlbumResponse.builder()
                .albums(albumItems)
                .build();
    }
}
