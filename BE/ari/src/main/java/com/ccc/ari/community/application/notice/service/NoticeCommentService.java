package com.ccc.ari.community.application.notice.service;

import com.ccc.ari.community.application.notice.command.CreateCommentCommand;
import com.ccc.ari.community.application.notice.repository.NoticeCommentRepository;
import com.ccc.ari.community.domain.notice.entity.NoticeComment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class NoticeCommentService {

    private final NoticeCommentRepository noticeCommentRepository;

    @Transactional
    public void saveNoticeComment(CreateCommentCommand command) {
        // 1. 댓글 도메인 엔티티를 생성합니다.
        NoticeComment comment = NoticeComment.builder()
                .noticeId(command.getNoticeId())
                .memberId(command.getMemberId())
                .content(command.getContent())
                .createdAt(LocalDateTime.now())
                .build();

        // 2. 공지사항 댓글을 저장합니다.
        noticeCommentRepository.saveNoticeComment(comment);
    }
}
