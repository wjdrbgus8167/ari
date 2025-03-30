package com.ccc.ari.chart.application.serviceImpl;

import com.ccc.ari.chart.event.ChartDataRequestEvent;
import com.ccc.ari.event.eventPublisher.EventPublisher;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Service
@RequiredArgsConstructor
public class ChartUpdateRequestService {

    private final EventPublisher eventPublisher;
    private static final Logger logger = LoggerFactory.getLogger(ChartUpdateRequestService.class);

    /**
     * 1시간마다 차트 갱신을 위한 데이터 요청 이벤트를 발행합니다.
     * 집계 도메인의 배치 작업(0분)이 완료된 후에 실행되도록 10분으로 설정합니다.
     */
    @Scheduled(cron = "0 10 * * * *")
    public void requestChartData() {
        logger.info("차트 갱신을 위한 데이터 요청을 시작합니다.");

        // 이전 시간대의 데이터 요청
        Instant previousHour = Instant.now().truncatedTo(ChronoUnit.HOURS).minus(Duration.ofHours(1));

        // 전체 차트 데이터 요청
        ChartDataRequestEvent allChartRequest = new ChartDataRequestEvent(previousHour);
        eventPublisher.publish(allChartRequest);
        logger.info("전체 차트 데이터 요청 이벤트 발행 완료");

        // 장르별 차트 데이터 요청
        // TODO: 추후 장르 가져오는 로직 구현하겠습니다.
        Integer genreId = 1;
        ChartDataRequestEvent genreChartRequest = new ChartDataRequestEvent(genreId, previousHour);
        eventPublisher.publish(genreChartRequest);
        logger.info("장르 ID: {} 차트 데이터 요청 이벤트 발행 완료", genreId);
    }

}
