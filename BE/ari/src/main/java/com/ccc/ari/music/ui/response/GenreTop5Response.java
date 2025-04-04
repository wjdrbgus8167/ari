package com.ccc.ari.music.ui.response;

import com.ccc.ari.music.domain.album.AlbumEntity;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class GenreTop5Response {

    private Integer albumId;
    private String albumTitle;
    private String coverImageUrl;
    private String description;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime releasedAt;

    private String genre;
    private Integer memberId;
    private String nickname;
    private Integer albumLikeCount;

    @Builder
    public GenreTop5Response(Integer albumId,String albumTitle,String coverImageUrl,String description
            ,LocalDateTime releasedAt,String genre,Integer memberId,String nickname,Integer albumLikeCount) {
        this.albumId = albumId;
        this.albumTitle = albumTitle;
        this.coverImageUrl = coverImageUrl;
        this.description = description;
        this.releasedAt = releasedAt;
        this.genre = genre;
        this.memberId = memberId;
        this.nickname = nickname;
        this.albumLikeCount = albumLikeCount;

    }


    public static GenreTop5Response from(AlbumEntity entity) {
        return GenreTop5Response.builder()
                .albumId(entity.getAlbumId())
                .albumTitle(entity.getAlbumTitle())
                .coverImageUrl(entity.getCoverImageUrl())
                .description(entity.getDescription())
                .releasedAt(entity.getReleasedAt())
                .genre(entity.getGenre().getGenreName())
                .memberId(entity.getMember().getMemberId())
                .nickname(entity.getMember().getNickname())
                .albumLikeCount(entity.getAlbumLikeCount())
                .build();
    }

}
