package com.ccc.ari.global.composition.controller.artist;

import com.ccc.ari.global.composition.response.artist.GetArtistPublicPlaylistResponse;
import com.ccc.ari.global.composition.service.artist.GetArtistPublicPlaylistService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/playlists")
@RequiredArgsConstructor
public class ArtistPublicPlaylistController {

    private final GetArtistPublicPlaylistService getArtistPublicPlaylistService;
    @GetMapping("/{memberId}/public")
    public ApiUtils.ApiResponse<GetArtistPublicPlaylistResponse> getArtistPublicPlaylist(
            @PathVariable Integer memberId
    ) {

        GetArtistPublicPlaylistResponse list = getArtistPublicPlaylistService.getArtistPublicPlaylist(memberId);
        return ApiUtils.success(list);
    }
}
