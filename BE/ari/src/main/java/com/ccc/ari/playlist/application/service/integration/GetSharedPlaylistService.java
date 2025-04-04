package com.ccc.ari.playlist.application.service.integration;

import com.ccc.ari.global.error.ApiException;
import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import com.ccc.ari.member.mapper.MemberMapper;
import com.ccc.ari.playlist.application.command.SharePlaylistCommand;
import com.ccc.ari.playlist.domain.playlist.Playlist;
import com.ccc.ari.playlist.domain.playlist.client.PlaylistClient;
import com.ccc.ari.playlist.domain.sharedplaylist.SharedPlaylistEntity;
import com.ccc.ari.playlist.domain.sharedplaylist.client.SharedPlaylistClient;
import com.ccc.ari.playlist.infrastructure.repository.sharedplaylist.JpaSharedPlaylistRepository;
import com.ccc.ari.playlist.mapper.PlaylistMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor

public class GetSharedPlaylistService {

    private final PlaylistClient playlistClient;
    private final JpaSharedPlaylistRepository jpaSharedPlaylistRepository;
    private final SharedPlaylistClient sharedPlaylistClient;
    private final MemberClient memberClient;
    private final PlaylistMapper playlistMapper;

    @Transactional
    public void sharePlaylist(SharePlaylistCommand command) {

        Playlist sharedPlaylist = playlistClient.getPlaylistById(command.getPlaylistId());
        // 퍼갈 원본 플레이리스트 조회
//        PlaylistEntity sharedPlaylist = jpaPlaylistRepository.findById(command.getPlaylistId())
//                .orElseThrow(() -> new ApiException(ErrorCode.PLAYLIST_NOT_FOUND));
//
        // 만약 이 플레이리스트가 비공개라면 에러 처리
        if (!sharedPlaylist.isPublicYn()) {
            throw new ApiException(ErrorCode.PLAYLIST_NOT_PUBLIC);
        }

        MemberDto member = memberClient.getMemberByMemberId(command.getMemberId());

        // 퍼가기 엔티티 생성 및 저장
        SharedPlaylistEntity shared = SharedPlaylistEntity.builder()
                .playlist(playlistMapper.mapToEntity(sharedPlaylist))
                .member(MemberMapper.toEntity(member))
                .createdAt(LocalDateTime.now())
                .build();

        jpaSharedPlaylistRepository.save(shared);

        // 공유 수 증가 (도메인 책임)
        playlistMapper.mapToEntity(sharedPlaylist).increaseShareCount();

    }
}
