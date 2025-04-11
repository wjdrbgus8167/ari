package com.ccc.ari.aggregation.infrastructure.repository;

import com.ccc.ari.aggregation.application.repository.StreamingLogRepository;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.SessionCallback;
import org.springframework.stereotype.Repository;

import java.util.Collections;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class StreamingLogRepositoryImpl implements StreamingLogRepository {

    private final RedisTemplate<String, StreamingLog> redisTemplate;

    @Override
    public void saveStreamingLogs(String key, StreamingLog streamingLog) {
        redisTemplate.opsForList().rightPush(key, streamingLog);
    }

    @Override
    public List<StreamingLog> getAllAndDelete(String key) {
        // 원자적 작업을 위해 Redis 트랜잭션 사용
        return redisTemplate.execute(new SessionCallback<List<StreamingLog>>() {
            @SuppressWarnings("unchecked")
            @Override
            public List<StreamingLog> execute(RedisOperations operations) throws DataAccessException {
                operations.multi();

                // 모든 요소 조회 (0부터 -1은 전체 리스트를 의미)
                operations.opsForList().range(key, 0, -1);

                // 키 삭제
                operations.delete(key);

                // 트랜잭션 실행 및 결과 반환
                List<Object> results = operations.exec();

                // 첫 번째 결과(range 명령의 결과)가 로그 리스트
                if (results != null && !results.isEmpty()) {
                    return (List<StreamingLog>) results.get(0);
                }

                return Collections.emptyList();
            }
        });
    }
}
