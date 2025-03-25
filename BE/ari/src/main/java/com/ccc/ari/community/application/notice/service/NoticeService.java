package com.ccc.ari.community.application.notice.service;

import com.ccc.ari.community.application.notice.command.CreateNoticeCommand;
import com.ccc.ari.community.application.notice.repository.NoticeRepository;
import com.ccc.ari.community.domain.notice.entity.Notice;
import com.ccc.ari.community.domain.notice.vo.NoticeContent;
import com.ccc.ari.global.infrastructure.S3Client;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

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
}
