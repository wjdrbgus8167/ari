package com.ccc.ari.playlist.domain.playlisttrack;

import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Entity
@Table(name = "playlist_tracks")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PlaylistTrackEntity {

    @Id
    @Column(name = "playlist_track_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer playlistTrackId;

    @Column(nullable = false)
    private Integer trackOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "playlist_id")
    private PlaylistEntity playlist;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "track_id")
    private TrackEntity track;


    @Builder
    public PlaylistTrackEntity(Integer trackOrder, PlaylistEntity playlist, TrackEntity track) {
        this.trackOrder = trackOrder;
        this.playlist = playlist;
        this.track = track;

    }
    public int getTrackOrder() {
        return trackOrder;
    }

}
