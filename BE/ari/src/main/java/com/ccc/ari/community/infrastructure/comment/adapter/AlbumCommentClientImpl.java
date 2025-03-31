package com.ccc.ari.community.infrastructure.comment.adapter;

import com.ccc.ari.community.domain.comment.entity.AlbumComment;
import com.ccc.ari.community.domain.comment.client.AlbumCommentClient;
import com.ccc.ari.community.infrastructure.comment.entity.AlbumCommentJpaEntity;
import com.ccc.ari.community.infrastructure.comment.repository.AlbumCommentJpaRepository;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/*
TODO : 임시 AlbumCommentClient 구현체
 */

/**
 * AlbumCommentClient 구현체
 */
@Component
@RequiredArgsConstructor
public class AlbumCommentClientImpl implements AlbumCommentClient {

    private final AlbumCommentJpaRepository albumCommentJpaRepository;

    @Override
    public List<AlbumComment> getAlbumCommentsByAlbumId(Integer albumId) {

        List<AlbumCommentJpaEntity> entities = albumCommentJpaRepository.findAllByAlbumIdAndDeletedYnFalse(albumId)
                .orElseThrow(()-> new ApiException(ErrorCode.ALBUM_COMMENT_NOT_FOUND));

        return entities.stream()
                .map(AlbumCommentJpaEntity::toDomain)
                .toList();
    }
}
