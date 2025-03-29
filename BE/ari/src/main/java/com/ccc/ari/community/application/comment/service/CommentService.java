package com.ccc.ari.community.application.comment.service;

import com.ccc.ari.community.application.comment.command.CreateAlbumCommentCommand;
import com.ccc.ari.community.application.comment.command.CreateTrackCommentCommand;
import com.ccc.ari.community.application.comment.repository.CommentRepository;
import com.ccc.ari.community.domain.comment.CommentType;
import com.ccc.ari.community.domain.comment.entity.AlbumComment;
import com.ccc.ari.community.domain.comment.entity.TrackComment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;

    // 앨범 댓글 생성
    @Transactional
    public void createAlbumComment(CreateAlbumCommentCommand command) {
        AlbumComment comment = AlbumComment.create(command.getAlbumId(), command.getMemberId(), command.getContent());
        commentRepository.saveComment(comment, CommentType.ALBUM);
    }

    // 트랙 댓글 생성
    @Transactional
    public void createTrackComment(CreateTrackCommentCommand command) {
        TrackComment comment = TrackComment.create(command.getTrackId(), command.getMemberId(), command.getContent(), command.getContentTimestamp());
        commentRepository.saveComment(comment, CommentType.TRACK);
    }
}
