package com.ccc.ari.playlist.domain.sharedplaylist;

import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Getter
@Entity
@Table(name = "shared_playlists")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class SharedPlaylistEntity {

    @Id
    @Column(name = "shared_playlist_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer sharedPlaylistId;

    // 퍼간 원본 플레이리스트
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "playlist_id", nullable = false)
    private PlaylistEntity playlist;

    // 퍼간 사용자
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private MemberEntity member;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    public SharedPlaylistEntity(PlaylistEntity playlist, MemberEntity member,LocalDateTime createdAt) {
        this.playlist = playlist;
        this.member = member;
        this.createdAt = createdAt;
    }

}
