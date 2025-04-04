package com.ccc.ari.community.application.fantalk.service;

import com.ccc.ari.community.application.fantalk.repository.FantalkChannelRepository;
import com.ccc.ari.community.domain.fantalk.entity.FantalkChannel;
import com.ccc.ari.member.event.MemberRegisterAndFantalkCreatedEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FantalkChannelCreationService {

    private final FantalkChannelRepository fantalkChannelRepository;
    private static final Logger logger = LoggerFactory.getLogger(FantalkChannelCreationService.class);

    /**
     * 회원 가입 이벤트를 수신하여 팬톡 채널 생성
     */
    @EventListener
    @Transactional
    public void handleMemberRegisteredEvent(MemberRegisterAndFantalkCreatedEvent event) {
        Integer memberId = event.memberId();
        logger.info("회원 가입 이벤트를 수신하였습니다. memberId: {}", memberId);

        // 팬톡 채널 생성
        FantalkChannel fantalkChannel = FantalkChannel.builder()
                .artistId(memberId)
                .build();

        fantalkChannelRepository.saveFantalkChannel(fantalkChannel);
        logger.info("팬톡 채널 생성을 완료했습니다.");
    }
}
