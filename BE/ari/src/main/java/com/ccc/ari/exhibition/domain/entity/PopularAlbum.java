package com.ccc.ari.exhibition.domain.entity;

import com.ccc.ari.exhibition.domain.vo.AlbumEntry;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * 인기 앨범 도메인 엔티티
 */
@Getter
public class PopularAlbum {

    private final Integer genreId;
    private final List<AlbumEntry> entries;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private final LocalDateTime createdAt;

    @Builder
    public PopularAlbum(Integer genreId, List<AlbumEntry> entries, LocalDateTime createdAt) {
        if (entries.size() > 10) {
            throw new IllegalArgumentException("인기 앨범은 최대 10개까지만 포함할 수 있습니다.");
        }

        this.genreId = genreId;
        this.entries = List.copyOf(entries);
        this.createdAt = createdAt;
    }

    @JsonCreator
    protected PopularAlbum() {
        this.genreId = null;
        this.entries = new ArrayList<>();
        this.createdAt = null;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof PopularAlbum album) {
            return album.getGenreId().equals(genreId) && album.getCreatedAt().equals(createdAt);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(genreId, createdAt);
    }
}
