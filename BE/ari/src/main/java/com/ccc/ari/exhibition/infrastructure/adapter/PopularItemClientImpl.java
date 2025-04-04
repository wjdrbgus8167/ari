package com.ccc.ari.exhibition.infrastructure.adapter;

import com.ccc.ari.exhibition.application.repository.PopularItemCacheRepository;
import com.ccc.ari.exhibition.application.repository.PopularItemRepository;
import com.ccc.ari.exhibition.domain.client.PopularItemClient;
import com.ccc.ari.exhibition.domain.entity.NewAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularPlaylist;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.common.quota.ClientQuotaAlteration;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class PopularItemClientImpl implements PopularItemClient {

    private final PopularItemCacheRepository<PopularAlbum> albumCacheRepository;
    private final PopularItemCacheRepository<PopularTrack> trackCacheRepository;
    private final PopularItemCacheRepository<PopularPlaylist> playlistCacheRepository;
    private final PopularItemCacheRepository<NewAlbum> newAlbumCacheRepository;
    private final PopularItemRepository<PopularAlbum> albumRepository;
    private final PopularItemRepository<PopularTrack> trackRepository;
    private final PopularItemRepository<PopularPlaylist> playlistRepository;
    private final PopularItemRepository<NewAlbum> newAlbumRepository;

    @Override
    public Optional<PopularAlbum> getLatestPopularAlbum(Integer genreId) {
        return albumCacheRepository.getLatestPopularItem(genreId)
                .or(() -> albumRepository.findLatestPopularItem(genreId)
                        .map(album -> {
                            albumCacheRepository.cachePopularItem(genreId, album);
                            return album;
                        }));
    }

    @Override
    public Optional<PopularTrack> getLatestPopularTrack(Integer genreId) {
        return trackCacheRepository.getLatestPopularItem(genreId)
                .or(() -> trackRepository.findLatestPopularItem(genreId)
                        .map(track -> {
                            trackCacheRepository.cachePopularItem(genreId, track);
                            return track;
                        }));
    }

    @Override
    public Optional<PopularPlaylist> getLatestPopularPlaylist() {
        return playlistCacheRepository.getLatestPopularItem(null)
                .or(() -> playlistRepository.findLatestPopularItem(null)
                        .map(playlist -> {
                            playlistCacheRepository.cachePopularItem(null, playlist);
                            return playlist;
                        }));
    }

    @Override
    public Optional<NewAlbum> getNewAlbum(Integer genreId) {
        return newAlbumCacheRepository.getLatestPopularItem(genreId)
                .or(() -> newAlbumRepository.findLatestPopularItem(genreId)
                        .map(newAlbum -> {
                            newAlbumCacheRepository.cachePopularItem(genreId, newAlbum);
                            return newAlbum;
                        }));
    }
}
