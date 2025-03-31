package com.ccc.ari.community.application.notice.service;

import com.ccc.ari.community.application.notice.command.CreateNoticeCommand;
import com.ccc.ari.community.application.notice.dto.NoticeListResponseDto;
import com.ccc.ari.community.application.notice.dto.NoticeResponseDto;
import com.ccc.ari.community.application.notice.repository.NoticeRepository;
import com.ccc.ari.community.domain.notice.entity.Notice;
import com.ccc.ari.community.domain.notice.vo.NoticeContent;
import com.ccc.ari.global.infrastructure.S3Client;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeRepository noticeRepository;
    private final S3Client s3Client;

    @Transactional
    public void saveNotice(CreateNoticeCommand command) {
        // 1. 공지사항 이미지를 S3에 업로드합니다.
        String imageUrl = null;
        if (command.getNoticeImage() != null && !command.getNoticeImage().isEmpty()) {
            imageUrl = s3Client.uploadImage(command.getNoticeImage(), "notice");
        }

        // 2. 공지사항 내용을 담고 있는 값 객체를 생성합니다.
        NoticeContent noticeContent = new NoticeContent(
                command.getNoticeContent(),
                imageUrl
        );

        // 3. 공지사항 도메인 엔티티를 생성합니다.
        Notice notice = Notice.builder()
                .artistId(command.getArtistId())
                .content(noticeContent)
                .createdAt(LocalDateTime.now())
                .build();

        // 4. 공지사항을 저장합니다.
        noticeRepository.saveNotice(notice);
    }

    @Transactional(readOnly = true)
    public NoticeListResponseDto getNoticeList(Integer artistId) {
        // 1. 공지사항 목록을 조회합니다.
        List<Notice> notices = noticeRepository.findAll(artistId);

        // 2. 공지사항 개수를 조회합니다.
        int count = noticeRepository.countByArtistId(artistId);

        // 3. 도메인 엔티티를 DTO로 변환합니다.
        List<NoticeResponseDto> noticeResponseDtos = notices.stream()
                .map(NoticeResponseDto::from)
                .toList();

        // 4. 응답 DTO를 생성하여 반환합니다.
        return NoticeListResponseDto.builder()
                .notices(noticeResponseDtos)
                .noticeCount(count)
                .build();
    }

    @Transactional(readOnly = true)
    public NoticeResponseDto getNotice(Integer noticeId) {
        // 1. 공지사항을 상세 조회합니다.
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new EntityNotFoundException("해당 공지사항이 없습니다. ID: " + noticeId));

        // 2. 도메인 엔티티를 DTO로 변환하여 반환합니다.
        return NoticeResponseDto.from(notice);
    }

    @Transactional(readOnly = true)
    public NoticeResponseDto getLatestNotice(Integer memberId) {
        // 1. 최근 공지사항을 조회합니다.
        Notice notice = noticeRepository.findByMemberId(memberId)
                .orElseThrow(() -> new EntityNotFoundException("등록된 공지사항이 없습니다."));

        // 2. 도메인 엔티티를 DTO로 변환하여 반환합니다.
        return NoticeResponseDto.from(notice);
    }
}
