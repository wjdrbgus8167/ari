package com.ccc.ari.exhibition.domain.vo;

import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.util.Objects;

@Getter
public class AlbumEntry {

    private final Integer albumId;
    private final long streamCount;

    @Builder
    public AlbumEntry(Integer albumId, long streamCount) {
        this.albumId = albumId;
        this.streamCount = streamCount;
    }

    @JsonCreator
    protected AlbumEntry() {
        this.albumId = null;
        this.streamCount = 0;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof AlbumEntry entry) {
            return entry.getAlbumId().equals(albumId);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(albumId);
    }
}
