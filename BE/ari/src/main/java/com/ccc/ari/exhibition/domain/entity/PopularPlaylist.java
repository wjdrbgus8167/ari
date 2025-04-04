package com.ccc.ari.exhibition.domain.entity;

import com.ccc.ari.exhibition.domain.vo.PlaylistEntry;
import com.fasterxml.jackson.annotation.JsonCreator;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * 인기 플레이리스트 도메인 엔티티
 */
@Getter
public class PopularPlaylist {

    private final List<PlaylistEntry> entries;
    private final LocalDateTime createdAt;

    @Builder
    public PopularPlaylist(List<PlaylistEntry> entries, LocalDateTime createdAt) {
        if (entries.size() > 5) {
            throw new IllegalArgumentException("인기 플레이리스틑 최대 5개까지만 포함할 수 있습니다.");
        }

        this.entries = List.copyOf(entries);
        this.createdAt = createdAt;
    }

    @JsonCreator
    protected PopularPlaylist() {
        this.entries = new ArrayList<>();
        this.createdAt = null;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof PopularPlaylist playlist) {
            return playlist.getCreatedAt().equals(createdAt);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(createdAt);
    }
}
