package com.ccc.ari.community.domain.fantalk.client;

public interface FantalkChannelClient {
    // 팬톡 채널 ID 조회
    FantalkChannelDto getFantalkChannelByArtistId(Integer artistId);
}
