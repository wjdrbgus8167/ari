package com.ccc.ari.exhibition.domain.entity;

import com.ccc.ari.exhibition.domain.vo.TrackEntry;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * 인기 트랙 도메인 엔티티
 */
@Getter
public class PopularTrack {

    private final Integer genreId;
    private final List<TrackEntry> entries;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private final LocalDateTime createdAt;

    @Builder
    public PopularTrack(Integer genreId, List<TrackEntry> entries, LocalDateTime createdAt) {
        if (entries.size() > 10) {
            throw new IllegalArgumentException("인기 트랙은 최대 10개까지만 포함할 수 있습니다.");
        }

        this.genreId = genreId;
        this.entries = List.copyOf(entries);
        this.createdAt = createdAt;
    }

    @JsonCreator
    protected PopularTrack() {
        this.genreId = null;
        this.entries = new ArrayList<>();
        this.createdAt = null;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof PopularTrack track) {
            return track.getGenreId().equals(genreId) && track.getCreatedAt().equals(createdAt);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(genreId, createdAt);
    }
}
