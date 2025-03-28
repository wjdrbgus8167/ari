package com.ccc.ari.community.application.like.service;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.application.like.repository.LikeRepository;
import com.ccc.ari.community.domain.like.entity.Like;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LikeService {

    private final LikeRepository likeRepository;

    @Transactional
    public void updateAlbumLike(LikeCommand command) {
        Integer albumId = command.getTargetId();
        Integer memberId = command.getMemberId();
        boolean activate = command.getActivateYn();

        Optional<Like> likeOptional = likeRepository.findByAlbumIdAndMemberId(albumId, memberId);

        if (likeOptional.isPresent()) {
            Like like = likeOptional.get();

            if (like.getActivateYn() == activate) {
                if (activate) {
                    throw new IllegalStateException("이미 좋아요한 앨범입니다.");
                } else {
                    throw new IllegalStateException("이미 좋아요가 취소된 상태입니다.");
                }
            }

            if (activate) {
                like.activate();
            } else {
                like.deactivate();
            }

            likeRepository.saveAlbumLike(like);
        } else if (activate) {
            Like newLike = Like.builder()
                    .targetId(albumId)
                    .memberId(memberId)
                    .build();

            likeRepository.saveAlbumLike(newLike);
        } else {
            throw new IllegalStateException("존재하지 않는 좋아요 상태입니다.");
        }
    }

    @Transactional
    public void updateTrackLike(LikeCommand command) {
        Integer trackId = command.getTargetId();
        Integer memberId = command.getMemberId();
        boolean activate = command.getActivateYn();

        Optional<Like> likeOptional = likeRepository.findByTrackIdAndMemberId(trackId, memberId);

        if (likeOptional.isPresent()) {
            Like like = likeOptional.get();

            if (like.getActivateYn() == activate) {
                if (activate) {
                    throw new IllegalStateException("이미 좋아요한 앨범입니다.");
                } else {
                    throw new IllegalStateException("이미 좋아요가 취소된 상태입니다.");
                }
            }

            if (activate) {
                like.activate();
            } else {
                like.deactivate();
            }

            likeRepository.saveTrackLike(like);
        } else if (activate) {
            Like newLike = Like.builder()
                    .targetId(trackId)
                    .memberId(memberId)
                    .build();

            likeRepository.saveTrackLike(newLike);
        } else {
            throw new IllegalStateException("존재하지 않는 좋아요 상태입니다.");
        }
    }
}
