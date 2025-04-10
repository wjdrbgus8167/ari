package com.ccc.ari.aggregation.infrastructure.config;

import io.ipfs.api.IPFS;
import io.ipfs.multihash.Multihash;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.*;

@Component
public class IpfsCacheManager {
    private static final Logger log = LoggerFactory.getLogger(IpfsCacheManager.class);

    private final Map<String, Long> cacheAccessTimes = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private final IPFS localNode;
    private final long maxCacheItems;
    private final boolean useLocalCache;

    public IpfsCacheManager(
            @Value("${IPFS_LOCAL_NODE_URL:/ip4/127.0.0.1/tcp/5001}") String localNodeUrl,
            @Value("${IPFS_CACHE_MAX_ITEMS:5000}") long maxCacheItems,
            @Value("${IPFS_USE_LOCAL_CACHE:true}") boolean useLocalCache,
            @Value("${IPFS_TIMEOUT:30000}") int timeout) {

        this.maxCacheItems = maxCacheItems;
        this.useLocalCache = useLocalCache;

        if (useLocalCache) {
            this.localNode = new IPFS(localNodeUrl);
            this.localNode.timeout(timeout);
            log.info("IPFS 캐시 관리자 초기화: 최대 캐시 항목 수={}", maxCacheItems);
        } else {
            this.localNode = null;
            log.info("IPFS 캐시 관리자: 캐싱 비활성화됨");
        }
    }

    @PostConstruct
    public void init() {
        if (!useLocalCache) return;

        // 캐시 정리 스케줄링 (1시간마다)
        scheduler.scheduleAtFixedRate(
                this::cleanupCache,
                1,
                1,
                TimeUnit.HOURS
        );
    }

    @PreDestroy
    public void cleanup() {
        scheduler.shutdownNow();
    }

    /**
     * 데이터 접근 시 액세스 시간 업데이트
     */
    public void recordAccess(String cid) {
        if (!useLocalCache) return;
        cacheAccessTimes.put(cid, System.currentTimeMillis());
    }

    /**
     * 정기적인 캐시 정리 (스케줄러에 의해 호출됨)
     */
    @Scheduled(fixedDelayString = "${IPFS_CACHE_CLEANUP_INTERVAL:3600000}")
    public void cleanupCache() {
        if (!useLocalCache || localNode == null) return;

        try {
            log.info("IPFS 캐시 정리 시작");

            // 로컬 노드에 핀된 항목 가져오기
            // 새 버전 변경 사항: 핀 목록을 가져오는 방식 변경
            List<Multihash> pinnedItems;
            try {
                Map<Multihash, Object> pins = localNode.pin.ls();
                pinnedItems = new CopyOnWriteArrayList<>(pins.keySet());
            } catch (Exception e) {
                log.error("핀 목록 가져오기 실패: {}", e.getMessage());
                return;
            }

            // 핀된 항목 수가 최대 수를 초과하는지 확인
            if (pinnedItems.size() <= maxCacheItems) {
                log.info("IPFS 캐시 정리 불필요: 현재 항목={}, 최대 항목={}", pinnedItems.size(), maxCacheItems);
                return;
            }

            // 가장 오래된 항목부터 제거 (최대 20% 정도)
            int itemsToRemove = (int) Math.ceil((pinnedItems.size() - maxCacheItems) * 1.2);

            // 가장 오래된 항목 찾기
            pinnedItems.stream()
                    .map(Multihash::toBase58)
                    .sorted((cid1, cid2) -> {
                        Long time1 = cacheAccessTimes.getOrDefault(cid1, 0L);
                        Long time2 = cacheAccessTimes.getOrDefault(cid2, 0L);
                        return time1.compareTo(time2);
                    })
                    .limit(itemsToRemove)
                    .forEach(cid -> {
                        try {
                            Multihash fileMultihash = Multihash.fromBase58(cid);
                            localNode.pin.rm(fileMultihash);
                            cacheAccessTimes.remove(cid);
                            log.info("IPFS 캐시에서 오래된 항목 제거됨: {}", cid);
                        } catch (Exception e) {
                            log.warn("항목 제거 중 오류 발생: {}", cid, e);
                        }
                    });

            log.info("IPFS 캐시 정리 완료: {}개 항목 제거됨", itemsToRemove);
        } catch (Exception e) {
            log.error("IPFS 캐시 정리 중 오류 발생", e);
        }
    }
}