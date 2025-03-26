package com.ccc.ari.community.infrastructure.notice.repository;

import com.ccc.ari.community.application.notice.repository.NoticeRepository;
import com.ccc.ari.community.domain.notice.entity.Notice;
import com.ccc.ari.community.infrastructure.notice.entity.NoticeJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import javax.swing.text.html.Option;
import java.util.List;
import java.util.Optional;

/**
 * 공지사항 리포지토리 구현체
 */
@Repository
@RequiredArgsConstructor
public class NoticeRepositoryImpl implements NoticeRepository {

    private final NoticeJpaRepository noticeJpaRepository;

    @Override
    public void saveNotice(Notice notice) {
        // 1. 도메인 엔티티를 JPA 엔티티로 변환합니다.
        NoticeJpaEntity jpaEntity = NoticeJpaEntity.fromDomain(notice);

        // 2. JPA 리포지토리를 통해 공지사항을 저장합니다.
        noticeJpaRepository.save(jpaEntity);
    }

    @Override
    public List<Notice> findAll(Integer artistId) {
        // 1. 특정 아티스트의 공지사항 목록을 조회합니다. (생성 일시 기준 내림차순 정렬)
        List<NoticeJpaEntity> noticeEntities = noticeJpaRepository.findByArtistIdAndDeletedYnFalseOrderByCreatedAtDesc(artistId);

        // 2. JPA 엔티티를 도메인 엔티티로 변환하여 반환합니다.
        return noticeEntities.stream()
                .map(NoticeJpaEntity::toDomain)
                .toList();
    }

    @Override
    public int countByArtistId(Integer artistId) {
        return noticeJpaRepository.countByArtistIdAndDeletedYnFalse(artistId);
    }

    @Override
    public Optional<Notice> findById(Integer noticeId) {
        return noticeJpaRepository.findByNoticeIdAndDeletedYnFalse(noticeId)
                .map(NoticeJpaEntity::toDomain);
    }
}
