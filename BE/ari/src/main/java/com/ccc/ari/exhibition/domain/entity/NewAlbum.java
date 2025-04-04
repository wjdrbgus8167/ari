package com.ccc.ari.exhibition.domain.entity;

import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * 최신 앨범 도메인 엔티티
 */
@Getter
public class NewAlbum {

    private final Integer genreId;
    private final List<AlbumEntry> entries;
    private final LocalDateTime createdAt;

    @Builder
    public NewAlbum(Integer genreId, List<AlbumEntry> entries, LocalDateTime createdAt) {
        if (entries.size() > 10) {
            throw new IllegalArgumentException("최신 앨범은 최대 10개까지만 포함할 수 있습니다.");
        }

        this.genreId = genreId;
        this.entries = List.copyOf(entries);
        this.createdAt = createdAt;
    }

    @JsonCreator
    protected NewAlbum() {
        this.genreId = null;
        this.entries = new ArrayList<>();
        this.createdAt = null;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof NewAlbum album) {
            return album.getGenreId().equals(genreId) && album.getCreatedAt().equals(createdAt);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(genreId, createdAt);
    }
}
