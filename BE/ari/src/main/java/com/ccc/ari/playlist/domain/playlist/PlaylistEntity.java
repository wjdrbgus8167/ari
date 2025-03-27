package com.ccc.ari.playlist.domain.playlist;

import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.music.domain.track.TrackEntity;
import com.ccc.ari.playlist.domain.playlisttrack.PlaylistTrackEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Entity
@Table(name = "playlists")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PlaylistEntity {

    @Id
    @Column(name = "playlist_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer playlistId;

    @Column(nullable = false, length = 100)
    private String playlistTitle;

    @Column(name = "created_at", nullable = false, updatable = false)
    @CreatedDate
    private LocalDateTime createdAt;

    @Column(name = "deleted_at", nullable = true)
    @CreatedDate
    private LocalDateTime deletedAt;

    @Column(name = "public_yn", nullable = false,columnDefinition = "BOOLEAN DEFAULT FALSE")
    private boolean publicYn;

    @Column(name = "share_count", nullable = false)
    private Integer shareCount = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private MemberEntity member;

    @OneToMany(mappedBy = "playlist", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PlaylistTrackEntity> tracks = new ArrayList<>();


    @Builder
    public PlaylistEntity(Integer playlistId, String playlistTitle,LocalDateTime createAt, MemberEntity member) {
        this.playlistId = playlistId;
        this.playlistTitle = playlistTitle;
        this.createdAt = createAt;
        this.member = member;
    }

    public void addTrack(TrackEntity track, int trackOrder) {
        PlaylistTrackEntity playlistTrack = PlaylistTrackEntity.builder()
                .track(track)
                .trackOrder(trackOrder)
                .playlist(this) //현재 PlaylistEntity 자기 자신
                .build();

        this.tracks.add(playlistTrack);
    }

    public void increaseShareCount() {
        this.shareCount++;
    }

    public void decreaseShareCount() {
        this.shareCount--;
    }

    public void setPublicYn() {
        this.publicYn = true;
    }
}
