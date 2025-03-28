package com.ccc.ari.music.domain.genre;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Entity
@Table(name = "genres")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class GenreEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "genre_id")
  private Integer genreId;

  @Column(nullable = false, length = 30)
  private String genreName;

  @Builder
  public GenreEntity(String genreName) {
    this.genreName = genreName;
  }
}