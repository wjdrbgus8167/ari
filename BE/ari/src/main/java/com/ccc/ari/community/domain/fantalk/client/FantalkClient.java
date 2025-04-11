package com.ccc.ari.community.domain.fantalk.client;

import java.util.List;

/**
 * 팬톡 도메인에 접근하기 위한 클라이언트 인터페이스
 * 예를 들어, Composition 레이어에서 접근할 수 있습니다.
 */
public interface FantalkClient {
    // 팬톡 전체 목록 조회
    List<FantalkDto> getFantalksByChannelId(Integer channelId);
}
