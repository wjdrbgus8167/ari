package com.ccc.ari.playlist.mapper;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.member.MemberEntity;
import com.ccc.ari.member.infrastructure.repository.member.JpaMemberRepository;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.PlaylistEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
@Component
@RequiredArgsConstructor
public class PlaylistMapper {

    private final JpaMemberRepository jpaMemberRepository;

    public PlaylistEntity mapToEntity(Playlist playList) {
        MemberEntity member = jpaMemberRepository.findById(playList.getMemberId())
                .orElseThrow(() -> new ApiException(ErrorCode.MEMBER_NOT_FOUND));

        return PlaylistEntity.builder()
                .playlistId(playList.getPlaylistId())
                .playlistTitle(playList.getPlayListTitle())
                .publicYn(playList.isPublicYn())
                .createAt(LocalDateTime.now())
                .member(member)
                .build();
    }

    public Playlist toDto(PlaylistEntity playList) {
        MemberEntity member = jpaMemberRepository.findById(playList.getMember().getMemberId())
                .orElseThrow(() -> new ApiException(ErrorCode.MEMBER_NOT_FOUND));

        return Playlist.builder()
                .playlistId(playList.getPlaylistId())
                .playListTitle(playList.getPlaylistTitle())
                .publicYn(playList.isPublicYn())
                .createdAt(playList.getCreatedAt())
                .shareCount(playList.getShareCount())
                .memberId(playList.getMember().getMemberId())
                .build();
    }

}
