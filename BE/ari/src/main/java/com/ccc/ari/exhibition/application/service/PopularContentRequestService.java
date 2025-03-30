package com.ccc.ari.exhibition.application.service;

import com.ccc.ari.event.eventPublisher.EventPublisher;
import com.ccc.ari.exhibition.event.PopularTracksRequestEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;

@Service
@RequiredArgsConstructor
public class PopularContentRequestService {

    private static final Logger logger = LoggerFactory.getLogger(PopularContentRequestService.class);
    private final EventPublisher eventPublisher;

    /**
     * 일주일 스트리밍 데이터 요청을 매일 오전 6시에 실행
     */
    @Scheduled(cron = "0 0 6 * * *")
    public void requestPopularTracks() {
        logger.info("인기 트랙 데이터 요청을 시작합니다.");

        // 주간 데이터 범위 설정 (현재 시점 기준 지난 7일)
        Instant now = Instant.now();
        Instant weekAgo = now.minus(Duration.ofDays(7));

        // 전체 스트리밍 데이터 요청
        PopularTracksRequestEvent allGenresRequest = new PopularTracksRequestEvent(weekAgo, now);
        eventPublisher.publish(allGenresRequest);
        logger.info("전체 장르 주간 인기 트랙 데이터 요청 이벤트 발행 완료");

        // 장르별 스트리밍 데이터 요청
        // TODO: 추후 장르 가져오는 로직 구현하겠습니다.
        Integer genreId = 1;
        PopularTracksRequestEvent genreRequest = new PopularTracksRequestEvent(genreId, weekAgo, now);
        eventPublisher.publish(genreRequest);
        logger.info("장르 ID: {} 주간 인기 트랙 데이터 요청 이벤트 발행 완료", genreId);
    }
}
