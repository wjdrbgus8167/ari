package com.ccc.ari.community.application.like.service;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.application.like.repository.AlbumLikeRepository;
import com.ccc.ari.community.domain.like.entity.AlbumLike;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AlbumLikeService {

    private final AlbumLikeRepository albumLikeRepository;

    @Transactional
    public void updateAlbumLike(LikeCommand command) {
        Integer albumId = command.getAlbumId();
        Integer memberId = command.getMemberId();
        boolean activate = command.getActivateYn();

        Optional<AlbumLike> likeOptional = albumLikeRepository.findByAlbumIdAndMemberId(albumId, memberId);

        if (likeOptional.isPresent()) {
            AlbumLike like = likeOptional.get();

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

            albumLikeRepository.saveAlbumLike(like);
        } else if (activate) {
            AlbumLike newLike = AlbumLike.builder()
                    .albumId(albumId)
                    .memberId(memberId)
                    .build();

            albumLikeRepository.saveAlbumLike(newLike);
        } else {
            throw new IllegalStateException("존재하지 않는 좋아요 상태입니다.");
        }
    }
}
