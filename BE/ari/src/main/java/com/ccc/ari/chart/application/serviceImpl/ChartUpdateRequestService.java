package com.ccc.ari.chart.application.serviceImpl;

import com.ccc.ari.chart.event.ChartDataRequestEvent;
import com.ccc.ari.event.eventPublisher.EventPublisher;
import com.ccc.ari.global.event.AllAggregationCalculatedEvent;
import com.ccc.ari.global.event.GenreAggregationCalculatedEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ChartUpdateRequestService {

    private static final Logger logger = LoggerFactory.getLogger(ChartUpdateRequestService.class);

    @EventListener
    public void requestAllChartData(AllAggregationCalculatedEvent event) {
        logger.info("전체 차트 갱신을 위한 이벤트를 수신했습니다.");

        Map<Integer, Long> allTrackCounts = event.getTrackCounts();
    }

    @EventListener
    public void requestGenreChartData(GenreAggregationCalculatedEvent event) {
        logger.info("장르 차트 갱신을 위한 이벤트를 수신했습니다.");

        Map<Integer, Map<Integer, Long>> genreTrackCount = event.getGenreTrackCounts();
    }
}
