package com.ccc.ari.playlist.infrastructure.adapter;

import com.ccc.ari.playlist.application.service.SharedPlaylistService;
import com.ccc.ari.playlist.domain.sharedplaylist.client.SharedPlaylistClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class SharedPlaylistClientImpl implements SharedPlaylistClient {

    private final SharedPlaylistService sharedPlaylistService;

    @Override
    public List<Integer> getSharedPlaylistIdByMemberId(Integer memberId) {
        return List.of();
    }

    @Override
    public Integer deleteSharedPlaylistByMemberIdAndPlaylistId(Integer memberId, Integer playlistId) {
        return sharedPlaylistService.deleteSharedPlaylistByMemberIdAndPlaylistId(memberId, playlistId);
    }


}
