package com.ccc.ari.community.domain.comment.client;

import com.ccc.ari.community.domain.comment.entity.AlbumComment;

import java.util.List;

/**
 * 앨범 댓글 도메인에 접근하기 위한 클라이언트 인터페이스
 */
public interface AlbumCommentClient {

    List<AlbumComment> getAlbumCommentsByAlbumId(Integer albumId);
}
