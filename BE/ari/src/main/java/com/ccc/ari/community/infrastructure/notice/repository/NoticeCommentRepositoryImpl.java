package com.ccc.ari.community.infrastructure.notice.repository;

import com.ccc.ari.community.application.notice.repository.NoticeCommentRepository;
import com.ccc.ari.community.domain.notice.entity.NoticeComment;
import org.springframework.stereotype.Repository;

@Repository
public class NoticeCommentRepositoryImpl implements NoticeCommentRepository {

    @Override
    public void saveNoticeComment(NoticeComment comment) {
    }
}
