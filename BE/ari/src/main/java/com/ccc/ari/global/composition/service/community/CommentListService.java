package com.ccc.ari.global.composition.service.community;

import com.ccc.ari.community.domain.comment.client.TrackCommentClient;
import com.ccc.ari.community.domain.comment.entity.Comment;
import com.ccc.ari.community.domain.comment.entity.TrackComment;
import com.ccc.ari.community.domain.notice.client.NoticeCommentClient;
import com.ccc.ari.community.domain.notice.client.NoticeCommentDto;
import com.ccc.ari.global.composition.response.community.NoticeCommentListResponse;
import com.ccc.ari.global.composition.response.community.TrackCommentListResponse;
import com.ccc.ari.member.domain.client.MemberClient;
import com.ccc.ari.member.domain.member.MemberDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CommentListService {

    private final NoticeCommentClient noticeCommentClient;
    private final MemberClient memberClient;
    private final TrackCommentClient trackCommentClient;

    public NoticeCommentListResponse getNoticeCommentList(Integer noticeId) {
        // 1. noticeId에 해당하는 댓글 목록을 조회합니다.
        List<NoticeCommentDto> comments = noticeCommentClient.getCommentsByNoticeId(noticeId);

        // 2. 댓글 작성자 ID 목록을 추출합니다.
        List<Integer> commenterIds = comments.stream()
                .map(NoticeCommentDto::getMemberId)
                .distinct()
                .toList();

        // 3. 작성자들의 회원 정보를 조회합니다.
        // TODO: N+1 문제 해결
        Map<Integer, MemberDto> memberInfoMap = new HashMap<>();
        for (Integer id : commenterIds) {
            MemberDto memberDto = memberClient.getMemberByMemberId(id);
            memberInfoMap.put(id, memberDto);
        }

        // 4. 응답 데이터를 구성합니다.
        return NoticeCommentListResponse.from(comments, memberInfoMap);
    }

    public TrackCommentListResponse getTrackCommentList(Integer trackId) {
        // 1. trackId에 해당하는 댓글 목록을 조회합니다.
        List<TrackComment> comments = trackCommentClient.getTrackCommentsByTrackId(trackId);
        int commentCount = trackCommentClient.countCommentsByTrackId(trackId);

        // 2. 댓글 작성자 ID 목록을 추출합니다.
        List<Integer> commenterIds = comments.stream()
                .map(Comment::getMemberId)
                .distinct()
                .toList();

        // 3. 작성자들의 회원 정보를 조회합니다.
        // TODO: N+1 문제 해결
        Map<Integer, MemberDto> memberInfoMap = new HashMap<>();
        for (Integer id : commenterIds) {
            MemberDto memberDto = memberClient.getMemberByMemberId(id);
            memberInfoMap.put(id, memberDto);
        }

        // 4. 응답 데이터를 구성합니다.
        return TrackCommentListResponse.from(comments, commentCount, memberInfoMap);
    }
}
