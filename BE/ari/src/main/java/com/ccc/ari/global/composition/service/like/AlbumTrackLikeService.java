package com.ccc.ari.global.composition.service.like;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.domain.like.LikeType;
import com.ccc.ari.community.domain.like.client.LikeClient;
import com.ccc.ari.community.domain.like.entity.Like;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.client.TrackClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AlbumTrackLikeService {

    private final LikeClient likeClient;
    private final AlbumClient albumClient;
    private final TrackClient trackClient;

    @Transactional
    public void updateLike(LikeCommand command, LikeType type) {
        Integer targetId = command.getTargetId();
        Integer memberId = command.getMemberId();
        boolean activate = command.getActivateYn();

        Optional<Like> likeOptional = likeClient.findByTargetAndMember(targetId, memberId, type);

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
                increaseLikeCount(targetId, type);
            } else {
                like.deactivate();
                decreaseLikeCount(targetId, type);
            }


            likeClient.saveLike(like, type);
        } else if (activate) {
            Like newLike = Like.builder()
                    .targetId(targetId)
                    .memberId(memberId)
                    .build();

            likeClient.saveLike(newLike, type);
            increaseLikeCount(targetId, type);
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

    private void increaseLikeCount(Integer targetId, LikeType type) {
        switch (type) {
            case ALBUM -> albumClient.increaseAlbumLikeCount(targetId);
            case TRACK -> trackClient.increaseTrackLikeCount(targetId);
        }
    }

    private void decreaseLikeCount(Integer targetId, LikeType type) {
        switch (type) {
            case ALBUM -> albumClient.decreaseAlbumLikeCount(targetId);
            case TRACK -> trackClient .decreaseTrackLikeCount(targetId);
        }
    }

}
