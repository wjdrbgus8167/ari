package com.ccc.ari.music.domain.album;

import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.music.domain.genre.GenreEntity;
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
@Table(name = "albums")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AlbumEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "album_id")
  private Integer albumId;

  @Column(nullable = false, length = 200)
  private String albumTitle;

  @CreatedDate
  @Column(name = "released_at", nullable = false, updatable = false)
  private LocalDateTime releasedAt;

  @Column(nullable = false, length = 2000)
  private String coverImageUrl;

  @Column(nullable = true, length = 1000)
  private String description;

  @Column(nullable=true, columnDefinition = "integer default 0")
  private Integer albumLikeCount;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "member_id")
  private MemberEntity member;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "genre_id")
  private GenreEntity genre;

  @Builder
  public AlbumEntity(Integer albumId,String albumTitle,LocalDateTime releasedAt,String coverImageUrl,String description
          ,Integer albumLikeCount,MemberEntity member,GenreEntity genre) {
    this.albumId = albumId;
    this.albumTitle = albumTitle;
    this.releasedAt = releasedAt;
    this.coverImageUrl = coverImageUrl;
    this.description = description;
    this.albumLikeCount = albumLikeCount;
    this.member = member;
    this.genre = genre;

  }

  public void increaseLikeCount() {
    this.albumLikeCount = (this.albumLikeCount == null ? 1 : this.albumLikeCount + 1);
  }

  public void decreaseLikeCount() {
    if (this.albumLikeCount != null && this.albumLikeCount > 0) {
      this.albumLikeCount -= 1;
    }
  }

}