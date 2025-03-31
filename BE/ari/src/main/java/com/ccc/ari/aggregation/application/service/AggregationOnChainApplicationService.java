package com.ccc.ari.aggregation.application.service;

import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.service.AggregationOnChainService;
import com.ccc.ari.aggregation.event.AggregationCompletedEvent;
import com.ccc.ari.aggregation.event.OnChainCommitCompletedEvent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AggregationOnChainApplicationService {

    private final AggregationOnChainService aggregationOnChainService;
    private final ApplicationEventPublisher eventPublisher;
    private final Logger logger = LoggerFactory.getLogger(AggregationOnChainApplicationService.class);

    /**
     * 집계 완료 이벤트를 처리하는 리스너 메소드
     * AggregationType에 따라 적절한 집계 처리 함수를 실행합니다.
     *
     * @param event AggregationCompletedEvent (집계 완료 이벤트)
     */
    @EventListener
    public void handleAggregationCompleted(AggregationCompletedEvent event) {
        switch (event.getAggregationType()) {
            case ALL:
                handleAllAggregation(event.getAggregatedData());
                break;
            case GENRE:
                handleGenreAggregation(event.getAggregatedData(), event.getSpecificId());
                break;
            case ARTIST:
                handleArtistAggregation(event.getAggregatedData(), event.getSpecificId());
                break;
            case LISTENER:
                handleListenerAggregation(event.getAggregatedData(), event.getSpecificId());
                break;
        }
    }

    // 전체 집계 이벤트 처리
    private void handleAllAggregation(AggregatedData aggregatedData) {
        // 도메인 서비스 aggregationOnChainService를 사용해 IPFS 저장 및 온체인 커밋
        String txHash = aggregationOnChainService.publishAggregatedData(aggregatedData);
        logger.info("집계된 데이터가 블록체인에 게시되었습니다, 트랜잭션 해시: {}", txHash);

        // OnChainCommitCompletedEvent 발행
        eventPublisher.publishEvent(new OnChainCommitCompletedEvent(txHash));
        logger.info("전체 커밋 완료 이벤트가 성공적으로 발행되었습니다.");
    }

    // 장르별 집계 이벤트 처리
    private void handleGenreAggregation(AggregatedData aggregatedData, Integer genreId) {
        String txHash = aggregationOnChainService.publishAggregatedDataByGenre(aggregatedData, genreId);
        logger.info("장르 ID {} 집계 데이터가 블록체인에 게시되었습니다, 트랜잭션 해시: {}", genreId, txHash);
    }

    // 아티스트별 집계 이벤트 처리
    private void handleArtistAggregation(AggregatedData aggregatedData, Integer artistId) {
        String txHash = aggregationOnChainService.publishAggregatedDataByArtist(aggregatedData, artistId);
        logger.info("아티스트 ID {} 집계 데이터가 블록체인에 게시되었습니다, 트랜잭션 해시: {}", artistId, txHash);
    }

    // 리스너별 집계 이벤트 처리
    private void handleListenerAggregation(AggregatedData aggregatedData, Integer listenerId) {
        String txHash = aggregationOnChainService.publishAggregatedDataByListener(aggregatedData, listenerId);
        logger.info("리스너 ID {} 집계 데이터가 블록체인에 게시되었습니다, 트랜잭션 해시: {}", listenerId, txHash);
    }
}
