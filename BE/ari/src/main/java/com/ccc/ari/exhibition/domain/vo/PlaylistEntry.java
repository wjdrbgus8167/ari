package com.ccc.ari.exhibition.domain.vo;

import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.util.Objects;

@Getter
public class PlaylistEntry {

    private final Integer playlistId;
    private final Integer shareCount;

    @Builder
    public PlaylistEntry(Integer playlistId, Integer shareCount) {
        this.playlistId = playlistId;
        this.shareCount = shareCount;
    }

    @JsonCreator
    protected PlaylistEntry() {
        this.playlistId = null;
        this.shareCount = 0;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof PlaylistEntry entry) {
            return entry.getPlaylistId().equals(playlistId);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(playlistId);
    }
}
