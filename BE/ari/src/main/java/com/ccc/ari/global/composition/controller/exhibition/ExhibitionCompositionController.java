package com.ccc.ari.global.composition.controller.exhibition;

import com.ccc.ari.global.composition.response.exhibition.NewAlbumResponse;
import com.ccc.ari.global.composition.response.exhibition.PopularAlbumResponse;
import com.ccc.ari.global.composition.response.exhibition.PopularPlaylistResponse;
import com.ccc.ari.global.composition.response.exhibition.PopularTrackResponse;
import com.ccc.ari.global.composition.service.exhibition.NewAlbumService;
import com.ccc.ari.global.composition.service.exhibition.PopularMusicService;
import com.ccc.ari.global.composition.service.exhibition.PopularPlaylistService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ExhibitionCompositionController {

    private final PopularMusicService popularMusicService;
    private final PopularPlaylistService popularPlaylistService;
    private final NewAlbumService newAlbumService;

    @GetMapping("/albums/popular")
    public ApiUtils.ApiResponse<PopularAlbumResponse> getAllPopularAlbums() {
        PopularAlbumResponse response = popularMusicService.getAllPopularAlbums();
        return ApiUtils.success(response);
    }

    @GetMapping("/albums/genres/{genreId}/popular")
    public ApiUtils.ApiResponse<PopularAlbumResponse> getGenrePopularAlbums(@PathVariable Integer genreId) {
        PopularAlbumResponse response = popularMusicService.getGenrePopularAlbums(genreId);
        return ApiUtils.success(response);
    }

    @GetMapping("/tracks/popular")
    public ApiUtils.ApiResponse<PopularTrackResponse> getAllPopularTracks() {
        PopularTrackResponse response = popularMusicService.getAllPopularTracks();
        return ApiUtils.success(response);
    }

    @GetMapping("/tracks/genres/{genreId}/popular")
    public ApiUtils.ApiResponse<PopularTrackResponse> getGenrePopularTracks(@PathVariable Integer genreId) {
        PopularTrackResponse response = popularMusicService.getGenrePopularTracks(genreId);
        return ApiUtils.success(response);
    }

    @GetMapping("/playlists/popular")
    public ApiUtils.ApiResponse<PopularPlaylistResponse> getPopularPlaylists() {
        PopularPlaylistResponse response = popularPlaylistService.getPopularPlaylists();
        return ApiUtils.success(response);
    }

    @GetMapping("/albums/new")
    public ApiUtils.ApiResponse<NewAlbumResponse> getAllNewAlbums() {
        NewAlbumResponse response = newAlbumService.getAllNewAlbums();
        return ApiUtils.success(response);
    }

    @GetMapping("/albums/genres/{genreId}/new")
    public ApiUtils.ApiResponse<NewAlbumResponse> getGenreNewAlbums(@PathVariable Integer genreId) {
        NewAlbumResponse response = newAlbumService.getGenreNewAlbums(genreId);
        return ApiUtils.success(response);
    }
}
