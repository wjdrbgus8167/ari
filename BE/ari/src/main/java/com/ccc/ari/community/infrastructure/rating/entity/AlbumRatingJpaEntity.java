package com.ccc.ari.community.infrastructure.rating.entity;

import com.ccc.ari.community.domain.rating.entity.AlbumRating;
import com.ccc.ari.community.domain.rating.vo.Rating;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Entity
@Table(name = "album_ratings")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AlbumRatingJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "album_rating_id")
    private Integer albumRatingId;

    @Column(name = "member_id")
    private Integer memberId;

    @Column(name = "album_id")
    private Integer albumId;

    @Column(name = "album_rating")
    private BigDecimal rating;

    private LocalDateTime updatedAt;

    @Builder
    public AlbumRatingJpaEntity(Integer memberId, Integer albumRatingId, Integer albumId, BigDecimal rating, LocalDateTime updatedAt) {
        this.memberId = memberId;
        this.albumRatingId = albumRatingId;
        this.albumId = albumId;
        this.rating = rating;
        this.updatedAt = updatedAt;
    }

    public static AlbumRatingJpaEntity toEntity(AlbumRating albumRating) {

        return AlbumRatingJpaEntity.builder()
                .memberId(albumRating.getMemberId())
                .albumId(albumRating.getAlbumId())
                .rating(albumRating.getRating().getValue())
                .updatedAt(albumRating.getUpdatedAt())
                .build();
    }

    public AlbumRating toDomain() {

        return AlbumRating.builder()
                .albumId(this.albumId)
                .memberId(this.memberId)
                .rating(new Rating(this.rating))
                .updatedAt(this.updatedAt)
                .build();
    }

    // 앨범 평점 업데이트
    public void updateRating(BigDecimal rating) {
        this.rating = rating;
    }

    // 마지막 앨범 평점 등록 시간 업데이트
    public void updateUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
