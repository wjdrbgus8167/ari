package com.ccc.ari.global.composition.infrastructure;

import com.ccc.ari.community.domain.comment.entity.AlbumComment;
import com.ccc.ari.community.infrastructure.comment.entity.AlbumCommentJpaEntity;
import com.ccc.ari.community.infrastructure.comment.repository.AlbumCommentJpaRepository;
import com.ccc.ari.music.mapper.TrackMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/*
TODO : 임시 AlbumCommentClient 구현체
 */
@Component
@RequiredArgsConstructor
public class AlbumCommentClientImpl implements AlbumCommentClient {

    private final AlbumCommentJpaRepository albumCommentJpaRepository;

    @Override
    public List<AlbumComment> getAlbumCommentsByAlbumId(Integer albumId) {
        List<AlbumCommentJpaEntity> entities = albumCommentJpaRepository.findAllByAlbumId(albumId);
        return entities.stream()
                .map(AlbumCommentJpaEntity::toDomain)
                .toList();
    }
}
