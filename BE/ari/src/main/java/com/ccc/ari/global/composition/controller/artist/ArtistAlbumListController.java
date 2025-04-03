package com.ccc.ari.global.composition.controller.artist;

import com.ccc.ari.global.composition.response.artiis.GetArtistAlbumListResponse;
import com.ccc.ari.global.composition.service.artist.GetArtisAlbumListService;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/artists")
@RequiredArgsConstructor
public class ArtistAlbumListController {
    private final GetArtisAlbumListService getArtisAlbumListService;

    @GetMapping("/{memberId}/albums")
    public ApiUtils.ApiResponse<List<GetArtistAlbumListResponse>> getArtistPublicPlaylist(
            @PathVariable Integer memberId) {

        List<GetArtistAlbumListResponse> response = getArtisAlbumListService.getArtisAlbumListService(memberId);

        return ApiUtils.success(response);
    }
}
