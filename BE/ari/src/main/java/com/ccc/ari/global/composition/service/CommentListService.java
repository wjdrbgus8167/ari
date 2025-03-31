package com.ccc.ari.global.composition.service;

import com.ccc.ari.community.domain.follow.client.FollowingDto;
import com.ccc.ari.community.domain.notice.client.NoticeCommentClient;
import com.ccc.ari.community.domain.notice.client.NoticeCommentDto;
import com.ccc.ari.global.composition.response.NoticeCommentListResponse;
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
}
