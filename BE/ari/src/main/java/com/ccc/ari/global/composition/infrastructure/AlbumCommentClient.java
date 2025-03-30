package com.ccc.ari.global.composition.infrastructure;

import com.ccc.ari.community.domain.comment.entity.AlbumComment;

import java.util.List;

/*
TODO : 임시 AlbumCommentClient interface, 추후 변경? 예정
 */
public interface AlbumCommentClient {

    List<AlbumComment> getAlbumCommentsByAlbumId(Integer albumId);
}
