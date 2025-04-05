package com.ccc.ari.global.composition.response.community;

import com.ccc.ari.community.domain.notice.client.NoticeCommentDto;
import com.ccc.ari.member.domain.member.MemberDto;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 공지사항 댓글 목록 조회 응답 DTO
 */
@Getter
@Builder
public class NoticeCommentListResponse {

    private List<CommentItem> comments;
    private int commentCount;

    public static NoticeCommentListResponse from(List<NoticeCommentDto> comments, Map<Integer, MemberDto> memberInfoMap) {
        List<CommentItem> commentItems = comments.stream()
                .map(comment -> {
                    Integer memberId = comment.getMemberId();
                    MemberDto memberInfo = memberInfoMap.get(memberId);

                    return CommentItem.builder()
                            .commentId(comment.getNoticeCommentId())
                            .memberId(comment.getMemberId())
                            .memberName(memberInfo.getNickname())
                            .profileImageUrl(memberInfo.getProfileImageUrl())
                            .content(comment.getContent())
                            .createdAt(comment.getCreatedAt())
                            .build();
                })
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
