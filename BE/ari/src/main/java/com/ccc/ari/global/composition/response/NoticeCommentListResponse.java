package com.ccc.ari.global.composition.response;

import com.ccc.ari.community.domain.notice.client.NoticeCommentDto;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 공지사항 댓글 목록 조회 응답 DTO
 */
@Getter
@Builder
public class NoticeCommentListResponse {

    private List<CommentItem> comments;
    private int commentCount;

    public static NoticeCommentListResponse from(List<NoticeCommentDto> comments) {
        List<CommentItem> commentItems = comments.stream()
                .map(comment -> CommentItem.builder()
                        .commentId(comment.getNoticeCommentId())
                        .memberId(comment.getMemberId())
                        .memberName("더미 작성자 이름")
                        .profileImageUrl("더미 프로필 이미지")
                        .content(comment.getContent())
                        .createdAt(comment.getCreatedAt())
                        .build())
                .toList();

        return NoticeCommentListResponse.builder()
                .comments(commentItems)
                .commentCount(comments.size())
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
        private String memberName;
        private String profileImageUrl;
        private String content;

        @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
        private LocalDateTime createdAt;
    }
}
