package com.ccc.ari.playlist.infrastructure.repository.playlist;

import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface JpaPlaylistRepository extends JpaRepository<PlaylistEntity, Integer> {
    // 사용자의 모든 플레이리스트 조회
    List<PlaylistEntity> findAllByMember_MemberId(Integer memberId);
    Optional<List<PlaylistEntity>> findAllByPublicYn(boolean publicYn);
    List<PlaylistEntity> findTop5ByOrderByShareCountDesc();
    List<PlaylistEntity> findAllByMember_MemberIdAndPublicYnTrue(Integer memberId);

}
