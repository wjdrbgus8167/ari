package com.ccc.ari.global.composition.response;

import com.ccc.ari.community.domain.comment.entity.TrackComment;
import com.ccc.ari.member.domain.member.MemberDto;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 트랙 댓글 목록 조회 응답 DTO
 */
@Getter
@Builder
public class TrackCommentListResponse {

    private List<CommentItem> comments;
    private int commentCount;

    public static TrackCommentListResponse from(List<TrackComment> comments, int commentCount, Map<Integer, MemberDto> memberInfoMap) {
        List<CommentItem> commentItems = comments.stream()
                .map(comment -> {
                    Integer memberId = comment.getMemberId();
                    MemberDto memberInfo = memberInfoMap.get(memberId);

                    return CommentItem.builder()
                            .commentId(comment.getCommentId())
                            .memberId(comment.getMemberId())
                            .nickname(memberInfo.getNickname())
                            .profileImageUrl(memberInfo.getProfileImageUrl())
                            .content(comment.getContent())
                            .timestamp(comment.getContentTimestamp())
                            .createdAt(comment.getCreatedAt())
                            .build();
                })
                .toList();

        return TrackCommentListResponse.builder()
                .comments(commentItems)
                .commentCount(commentCount)
                .build();
    }

    /**
     * 댓글 상세 정보를 담는 내부 클래스
     */
    @Getter
    @Builder
    public static class CommentItem {
        private Integer commentId;
        private Integer memberId;
        private String nickname;
        private String profileImageUrl;
        private String content;
        private String timestamp;

        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime createdAt;
    }
}
