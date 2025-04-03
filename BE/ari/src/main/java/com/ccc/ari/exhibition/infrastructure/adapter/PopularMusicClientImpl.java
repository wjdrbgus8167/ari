package com.ccc.ari.exhibition.infrastructure.adapter;

import com.ccc.ari.exhibition.application.repository.PopularMusicCacheRepository;
import com.ccc.ari.exhibition.application.repository.PopularMusicRepository;
import com.ccc.ari.exhibition.domain.client.PopularMusicClient;
import com.ccc.ari.exhibition.domain.entity.PopularAlbum;
import com.ccc.ari.exhibition.domain.entity.PopularTrack;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class PopularMusicClientImpl implements PopularMusicClient {

    private final PopularMusicCacheRepository<PopularAlbum> albumCacheRepository;
    private final PopularMusicCacheRepository<PopularTrack> trackCacheRepository;
    private final PopularMusicRepository<PopularAlbum> albumRepository;
    private final PopularMusicRepository<PopularTrack> trackRepository;

    @Override
    public Optional<PopularAlbum> getLatestPopularAlbum(Integer genreId) {
        return albumCacheRepository.getLatestPopularMusic(genreId)
                .or(() -> albumRepository.findLatestPopularMusic(genreId)
                        .map(album -> {
                            albumCacheRepository.cachePopularMusic(genreId, album);
                            return album;
                        }));
    }

    @Override
    public Optional<PopularTrack> getLatestPopularTrack(Integer genreId) {
        return trackCacheRepository.getLatestPopularMusic(genreId)
                .or(() -> trackRepository.findLatestPopularMusic(genreId)
                        .map(track -> {
                            trackCacheRepository.cachePopularMusic(genreId, track);
                            return track;
                        }));
    }
}
