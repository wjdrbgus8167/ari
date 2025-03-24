package com.ccc.ari.community.application.fantalk.repository;

import com.ccc.ari.community.domain.fantalk.entity.Fantalk;

/**
 * 팬톡 리포지토리 인터페이스
 */
public interface FantalkRepository {
    // 팬톡 저장
    Fantalk saveFantalk(Fantalk fantalk);
}
