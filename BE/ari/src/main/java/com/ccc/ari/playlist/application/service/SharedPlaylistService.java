package com.ccc.ari.playlist.application.service;

import com.ccc.ari.playlist.infrastructure.repository.sharedplaylist.JpaSharedPlaylistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;


@Component
@RequiredArgsConstructor
public class SharedPlaylistService {

    private final JpaSharedPlaylistRepository jpaSharedPlaylistRepository;

    @Transactional
    public Integer deleteSharedPlaylistByMemberIdAndPlaylistId(Integer memberId, Integer playlistId) {

        return jpaSharedPlaylistRepository.deleteByMember_MemberIdAndPlaylist_PlaylistId(memberId, playlistId);
    }


}
