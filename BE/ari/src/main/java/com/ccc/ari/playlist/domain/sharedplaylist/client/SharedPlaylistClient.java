package com.ccc.ari.playlist.domain.sharedplaylist.client;

import com.ccc.ari.playlist.domain.sharedplaylist.SharedPlaylistEntity;

import java.util.List;

public interface SharedPlaylistClient {

    /*
        memberId로 퍼온 플레이리스트 조회
        return -> playlistId
     */
    List<Integer> getSharedPlaylistIdByMemberId(Integer memberId);
    Integer deleteSharedPlaylistByMemberIdAndPlaylistId(Integer memberId, Integer playlistId);
}
