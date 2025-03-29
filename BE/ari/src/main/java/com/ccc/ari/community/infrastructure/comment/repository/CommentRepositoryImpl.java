package com.ccc.ari.community.infrastructure.comment.repository;

import com.ccc.ari.community.application.comment.repository.CommentRepository;
import com.ccc.ari.community.domain.comment.CommentType;
import com.ccc.ari.community.domain.comment.entity.AlbumComment;
import com.ccc.ari.community.domain.comment.entity.Comment;
import com.ccc.ari.community.domain.comment.entity.TrackComment;
import com.ccc.ari.community.infrastructure.comment.entity.AlbumCommentJpaEntity;
import com.ccc.ari.community.infrastructure.comment.entity.TrackCommentJpaEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * Comment 리포지토리 구현체
 */
@Component
@RequiredArgsConstructor
public class CommentRepositoryImpl implements CommentRepository {

    private final AlbumCommentJpaRepository albumCommentJpaRepository;
    private final TrackCommentJpaRepository trackCommentJpaRepository;

    @Override
    public void saveComment(Comment comment, CommentType type) {
        switch (type) {
            case ALBUM:
                AlbumComment albumComment = (AlbumComment) comment;
                AlbumCommentJpaEntity albumEntity = AlbumCommentJpaEntity.fromDomain(albumComment);
                albumCommentJpaRepository.save(albumEntity);
                break;
            case TRACK:
                TrackComment trackComment = (TrackComment) comment;
                TrackCommentJpaEntity trackEntity = TrackCommentJpaEntity.fromDomain(trackComment);
                trackCommentJpaRepository.save(trackEntity);
                break;
        }
    }
}
