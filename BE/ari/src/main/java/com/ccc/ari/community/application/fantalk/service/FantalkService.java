package com.ccc.ari.community.application.fantalk.service;

import com.ccc.ari.community.application.fantalk.repository.FantalkRepository;
import com.ccc.ari.community.domain.fantalk.entity.Fantalk;
import com.ccc.ari.community.domain.fantalk.vo.FantalkContent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class FantalkService {

    private final FantalkRepository fantalkRepository;
    private static final Logger logger = LoggerFactory.getLogger(FantalkService.class);

    @Transactional
    public void createFantalk(Integer memberId, Integer fantalkChannelId, String content, Integer trackId, String fantalkImageUrl) {
        // 1. 팬톡 내용을 담고 있는 값 객체를 생성합니다.
        FantalkContent contentVO = new FantalkContent(content, trackId, fantalkImageUrl);
        logger.info("팬톡 내용 VO 생성: {}", contentVO);

        // 2. 팬톡 도메인 엔티티를 생성합니다.
        Fantalk fantalk = Fantalk.builder()
                .fantalkChannelId(fantalkChannelId)
                .memberId(memberId)
                .content(contentVO)
                .createdAt(LocalDateTime.now())
                .build();
        logger.info("팬톡 도메인 엔티티 생성: {}", fantalk);

        // 3. 팬톡을 저장합니다.
        Fantalk savedFantalk = fantalkRepository.saveFantalk(fantalk);
        logger.info("팬톡 저장 완료: fantalkId={}", savedFantalk.getFantalkId());
    }
}
