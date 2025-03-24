package com.ccc.ari.community.domain.fantalk.vo;

import lombok.Getter;

import java.util.Objects;

/**
 * 팬톡 내용 값 객체
 */
@Getter
public class FantalkContent {

    private final String content;
    private final Integer trackId;
    private final String fantalkImageUrl;

    public FantalkContent(String content, Integer trackId, String fantalkImageUrl) {
        validateContent(content);

        this.content = content;
        this.trackId = trackId;
        this.fantalkImageUrl = fantalkImageUrl;
    }

    private void validateContent(String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("팬톡 내용은 필수입니다.");
        }

        if (content.length() > 1000) {
            throw new IllegalArgumentException("팬톡 내용은 1000자를 초과할 수 없습니다.");
        }
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof FantalkContent fantalkContent) {
            return fantalkContent.getContent().equals(content) && fantalkContent.getTrackId().equals(trackId) && fantalkContent.getFantalkImageUrl().equals(fantalkImageUrl);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(content, trackId, fantalkImageUrl);
    }

    @Override
    public String toString() {
        return "content=" + content + "\n" + "trackId=" + trackId + "\n" + "image=" + fantalkImageUrl;
    }
}
