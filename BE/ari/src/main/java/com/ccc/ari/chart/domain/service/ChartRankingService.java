package com.ccc.ari.chart.domain.service;

import com.ccc.ari.chart.domain.vo.ChartEntry;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 차트 순위 계산 로직을 처리하는 도메인 서비스
 */
@Service
@RequiredArgsConstructor
public class ChartRankingService {

    private static final Logger logger = LoggerFactory.getLogger(ChartRankingService.class);
    private static final int MAX_CHART_SIZE = 20;

    public List<ChartEntry> calculateRankings(Map<Integer, Long> streamCounts) {

        // 스트리밍 횟수를 기준으로 내림차순 정렬
        List<Map.Entry<Integer, Long>> sortedEntries = streamCounts.entrySet().stream()
                .sorted(Map.Entry.<Integer, Long>comparingByValue().reversed())
                .limit(MAX_CHART_SIZE)
                .toList();

        // 순위 계산
        List<ChartEntry> entries = new ArrayList<>();
        int currentRank = 1;      // 현재 순위
        long previousCount = -1;  // 이전 트랙의 스트리밍 횟수
        int position = 1;         // 현재 위치 (공동 순위가 아닌 실제 위치)

        for (Map.Entry<Integer, Long> entry : sortedEntries) {
            Integer trackId = entry.getKey();
            Long count = entry.getValue();

            // 이전 트랙과 스트리밍 횟수가 다른 경우 현재 위치를 순위로 설정
            if (count != previousCount) {
                currentRank = position;
            }

            entries.add(ChartEntry.builder()
                    .trackId(trackId)
                    .streamCount(count)
                    .rank(currentRank)
                    .build());

            previousCount = count;
            position++;
        }

        logger.info("차트 순위 계산 완료: {}개 트랙", entries.size());
        return entries;
    }
}
