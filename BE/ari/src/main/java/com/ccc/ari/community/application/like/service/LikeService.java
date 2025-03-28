package com.ccc.ari.community.application.like.service;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.application.like.repository.LikeRepository;
import com.ccc.ari.community.domain.like.LikeType;
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
    public void updateLike(LikeCommand command, LikeType type) {
        Integer targetId = command.getTargetId();
        Integer memberId = command.getMemberId();
        boolean activate = command.getActivateYn();

        Optional<Like> likeOptional = likeRepository.findByTargetAndMember(targetId, memberId, type);

        if (likeOptional.isPresent()) {
            Like like = likeOptional.get();

            if (like.getActivateYn() == activate) {
                if (activate) {
                    throw new IllegalStateException("이미 좋아요한 상태입니다.");
                } else {
                    throw new IllegalStateException("이미 좋아요가 취소된 상태입니다.");
                }
            }

            if (activate) {
                like.activate();
            } else {
                like.deactivate();
            }

            likeRepository.saveLike(like, type);
        } else if (activate) {
            Like newLike = Like.builder()
                    .targetId(targetId)
                    .memberId(memberId)
                    .build();

            likeRepository.saveLike(newLike, type);
        } else {
            throw new IllegalStateException("존재하지 않는 좋아요 상태입니다.");
        }
    }

    // 앨범 좋아요
    @Transactional
    public void updateAlbumLike(LikeCommand command) {
        updateLike(command, LikeType.ALBUM);
    }

    // 트랙 좋아요
    @Transactional
    public void updateTrackLike(LikeCommand command) {
        updateLike(command, LikeType.TRACK);
    }
}
