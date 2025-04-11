package com.ccc.ari.community.infrastructure.notice.entity;

import com.ccc.ari.community.domain.notice.entity.Notice;
import com.ccc.ari.community.domain.notice.vo.NoticeContent;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Notice JPA 엔티티
 */
@Entity
@Table(name = "notices")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class NoticeJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notice_id", nullable = false)
    private Integer noticeId;

    @Column(name = "artist_id", nullable = false)
    private Integer artistId;

    @Column(name = "notice_content", nullable = false, length = 2000)
    private String noticeContent;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "deleted_yn", nullable = false, columnDefinition = "boolean default false")
    private Boolean deletedYn;

    @Column(name = "notice_image_url", length = 2000)
    private String noticeImageUrl;

    @Builder
    public NoticeJpaEntity(Integer noticeId, Integer artistId, String noticeContent, LocalDateTime createdAt, Boolean deletedYn, String noticeImageUrl) {
        this.noticeId = noticeId;
        this.artistId = artistId;
        this.noticeContent = noticeContent;
        this.createdAt = createdAt;
        this.deletedYn = deletedYn;
        this.noticeImageUrl = noticeImageUrl;
    }

    /**
     * 도메인 엔티티를 JPA 엔티티로 변환하는 메서드
     */
    public static NoticeJpaEntity fromDomain(Notice notice) {
        return NoticeJpaEntity.builder()
                .noticeId(notice.getNoticeId())
                .artistId(notice.getArtistId())
                .noticeContent(notice.getContent().getContent())
                .noticeImageUrl(notice.getContent().getNoticeImageUrl())
                .createdAt(notice.getCreatedAt())
                .deletedYn(notice.getDeletedYn())
                .build();
    }

    /**
     * JPA 엔티티를 도메인 엔티티로 변환하는 메서드
     */
    public Notice toDomain() {
        NoticeContent content = new NoticeContent(noticeContent, noticeImageUrl);

        return Notice.builder()
                .noticeId(noticeId)
                .artistId(artistId)
                .content(content)
                .createdAt(createdAt)
                .deletedYn(deletedYn)
                .build();
    }
}
