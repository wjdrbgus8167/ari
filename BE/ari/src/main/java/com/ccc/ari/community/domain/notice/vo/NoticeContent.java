package com.ccc.ari.community.domain.notice.vo;

import lombok.Getter;

import java.util.Objects;

/**
 * 공지사항 내용 값 객체
 */
@Getter
public class NoticeContent {

    private final String content;
    private final String noticeImageUrl;

    public NoticeContent(String content, String noticeImageUrl) {
        validateContent(content);

        this.content = content;
        this.noticeImageUrl = noticeImageUrl;
    }

    private void validateContent(String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("공지사항 내용은 필수입니다.");
        }

        if (content.length() > 2000) {
            throw new IllegalArgumentException("공지사항 내용은 2000자를 초과할 수 없습니다.");
        }
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof NoticeContent noticeContent) {
            return noticeContent.getContent().equals(content) && noticeContent.getNoticeImageUrl().equals(noticeImageUrl);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(content, noticeImageUrl);
    }
}
