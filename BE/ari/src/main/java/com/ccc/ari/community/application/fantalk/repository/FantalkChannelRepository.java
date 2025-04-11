package com.ccc.ari.community.application.fantalk.repository;

import com.ccc.ari.community.domain.fantalk.entity.FantalkChannel;

/**
 * 팬톡 채널 리포지토리 인터페이스
 */
public interface FantalkChannelRepository {
    // 팬톡 채널 생성
    void saveFantalkChannel(FantalkChannel fantalkChannel);
}
