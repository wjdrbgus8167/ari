package com.ccc.ari.community.infrastructure.comment.adapter;

import com.ccc.ari.community.domain.comment.client.TrackCommentClient;
import com.ccc.ari.community.domain.comment.entity.TrackComment;
import com.ccc.ari.community.infrastructure.comment.entity.TrackCommentJpaEntity;
import com.ccc.ari.community.infrastructure.comment.repository.TrackCommentJpaRepository;
import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/*
    트랙 댓글 구현체
    TODO : 추후에 수정 or 변경 예정. 아직 임시
 */
@Component
@RequiredArgsConstructor
public class TrackCommentClientImpl implements TrackCommentClient {

    private final TrackCommentJpaRepository trackCommentJpaRepository;

    @Override
    public List<TrackComment> getTrackCommentsByTrackId(Integer trackId) {
        List<TrackCommentJpaEntity> entities = trackCommentJpaRepository.findAllByTrackId(trackId)
                .orElseThrow(()-> new ApiException(ErrorCode.TRACK_COMMENT_NOT_FOUND));

        return entities.stream()
                .map(TrackCommentJpaEntity::toDomain)
                .toList();
    }

}
