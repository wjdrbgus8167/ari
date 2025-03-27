package com.ccc.ari.playlist.infrastructure;

import com.ccc.ari.playlist.domain.sharedplaylist.SharedPlaylistEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface JpaSharedPlaylistRepository extends JpaRepository<SharedPlaylistEntity, Integer> {
    // 자신이 퍼온 플레이리스트를 모두 조회
    List<SharedPlaylistEntity> findAllByMember_MemberId(Integer playlistId);
    // 자신이 퍼온 플레이리스트를 삭제
    int deleteByMember_MemberIdAndPlaylist_PlaylistId(Integer memberId, Integer playlistId);

}
