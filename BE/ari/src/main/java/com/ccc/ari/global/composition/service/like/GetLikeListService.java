package com.ccc.ari.global.composition.service.like;

import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.client.LikeClient;
import com.ccc.ari.community.domain.like.entity.Like;
import com.ccc.ari.global.composition.response.community.LikeAlbumListResponse;
import com.ccc.ari.global.composition.response.community.LikeTrackListResponse;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GetLikeListService {

    private final LikeClient likeClient;
    private final AlbumClient albumClient;
    private final TrackClient trackClient;

    @Transactional(readOnly = true)
    public LikeAlbumListResponse getLikeAlbumList(Integer memberId) {
        List<Like> albumLikes = likeClient.findAllByMember(memberId, LikeType.ALBUM);

        List<LikeAlbumListResponse.AlbumItem> albumItems = new ArrayList<>();
        for (Like like : albumLikes) {
            AlbumDto albumDto = albumClient.getAlbumById(like.getTargetId());
            Integer albumId = albumDto.getAlbumId();
            Integer trackCount = trackClient.countTracksByAlbumId(albumId);

            LikeAlbumListResponse.AlbumItem albumItem = LikeAlbumListResponse.AlbumItem.builder()
                    .albumId(albumId)
                    .albumTitle(albumDto.getTitle())
                    .artist(albumDto.getArtist())
                    .coverImageUrl(albumDto.getCoverImageUrl())
                    .trackCount(trackCount)
                    .build();

            albumItems.add(albumItem);
        }

        return LikeAlbumListResponse.builder()
                .albums(albumItems)
                .albumCount(albumItems.size())
                .build();
    }

    @Transactional(readOnly = true)
    public LikeTrackListResponse getLikeTrackList(Integer memberId) {
        List<Like> trackLikes = likeClient.findAllByMember(memberId, LikeType.TRACK);

        List<LikeTrackListResponse.TrackItem> trackItems = new ArrayList<>();
        for (Like like : trackLikes) {
            TrackDto trackDto = trackClient.getTrackById(like.getTargetId());
            AlbumDto albumDto = albumClient.getAlbumById(trackDto.getAlbumId());

            LikeTrackListResponse.TrackItem trackItem = LikeTrackListResponse.TrackItem.builder()
                    .trackId(trackDto.getTrackId())
                    .trackTitle(trackDto.getTitle())
                    .artist(albumDto.getArtist())
                    .coverImageUrl(albumDto.getCoverImageUrl())
                    .build();

            trackItems.add(trackItem);
        }

        return LikeTrackListResponse.builder()
                .tracks(trackItems)
                .trackCount(trackItems.size())
                .build();
    }
}
