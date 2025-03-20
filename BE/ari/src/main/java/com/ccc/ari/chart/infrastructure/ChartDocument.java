package com.ccc.ari.chart.infrastructure;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.List;

@Document(collection = "charts")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ChartDocument {
    @Id
    private String id;

    @Indexed
    private Instant startDate;

    @Indexed
    private Instant endDate;

    private Instant createdAt;

    private List<ChartEntryDocument> entries;

    @Builder
    public ChartDocument(String id, Instant startDate, Instant endDate, Instant createdAt, List<ChartEntryDocument> entries) {
        this.id = id;
        this.startDate = startDate;
        this.endDate = endDate;
        this.createdAt = createdAt;
        this.entries = entries;
    }

    @Getter
    @NoArgsConstructor(access = AccessLevel.PROTECTED)
    public static class ChartEntryDocument {
        private Integer trackId;
        private String trackTitle;
        private String artist;
        private String coverImageUrl;
        private int rank;
        private long streamCount;

        @Builder
        public ChartEntryDocument(Integer trackId, String trackTitle, String artist, String coverImageUrl, int rank, long streamCount) {
            this.trackId = trackId;
            this.trackTitle = trackTitle;
            this.artist = artist;
            this.coverImageUrl = coverImageUrl;
            this.rank = rank;
            this.streamCount = streamCount;
        }
    }
}
