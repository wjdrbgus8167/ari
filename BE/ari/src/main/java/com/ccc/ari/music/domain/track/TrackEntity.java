package com.ccc.ari.music.domain.track;

import com.ccc.ari.music.domain.album.AlbumEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Entity
@Table(name = "tracks")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TrackEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "track_id")
    private Integer trackId;

    @Column(nullable = false, length = 1000)
    private String trackTitle;

    @Column(nullable = false)
    private Integer trackNumber;

    @Column(nullable = false,length = 1000)
    private String composer;

    @Column(nullable = false, length = 1000)
    private String lyricist;

    @Column(nullable = false, length = 2000)
    private String trackFileUrl;

    @Column(nullable = true, length = 2000)
    private String lyrics;

    @Column(nullable=true, columnDefinition = "integer default 0")
    private Integer trackLikeCount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "album_id")
    private AlbumEntity album;

    @Builder
    public TrackEntity(Integer trackId,String trackTitle, Integer trackNumber, String composer
            , String lyricist, String trackFileUrl, String lyrics, Integer trackLikeCount
            , AlbumEntity album) {

        this.trackId = trackId;
        this.trackTitle = trackTitle;
        this.trackNumber = trackNumber;
        this.composer = composer;
        this.lyricist = lyricist;
        this.trackFileUrl = trackFileUrl;
        this.lyrics = lyrics;
        this.trackLikeCount = trackLikeCount;
        this.album = album;

    }
}