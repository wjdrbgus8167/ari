package com.ccc.ari.community.application.comment.repository;

import com.ccc.ari.community.domain.comment.CommentType;
import com.ccc.ari.community.domain.comment.entity.Comment;

/**
 * Comment 리포지토리 인터페이스
 */
public interface CommentRepository {

    // 댓글 저장
    void saveComment(Comment comment, CommentType type);
}
