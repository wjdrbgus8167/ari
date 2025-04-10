package com.ccc.ari.aggregation.infrastructure.config;

import io.ipfs.api.IPFS;
import io.ipfs.multihash.Multihash;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

@Component
public class IpfsCacheManager {
    private static final Logger log = LoggerFactory.getLogger(IpfsCacheManager.class);
    private static final int THREAD_POOL_SIZE = 2;
    private static final int SHUTDOWN_TIMEOUT_SECONDS = 60;

    private final Map<String, Long> cacheAccessTimes = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler;
    private final ExecutorService cacheExecutor;
    private final IPFS localNode;
    private final long maxCacheItems;
    private final boolean useLocalCache;

    public IpfsCacheManager(
            @Value("${IPFS_LOCAL_NODE_URL}") String localNodeUrl,
            @Value("${IPFS_CACHE_MAX_ITEMS:5000}") long maxCacheItems,
            @Value("${IPFS_USE_LOCAL_CACHE}") boolean useLocalCache,
            @Value("${IPFS_TIMEOUT:15000}") int timeout) {

        this.maxCacheItems = validateMaxCacheItems(maxCacheItems);
        this.useLocalCache = useLocalCache;
        this.scheduler = Executors.newScheduledThreadPool(1,
                new CustomThreadFactory("ipfs-cache-scheduler"));
        this.cacheExecutor = Executors.newFixedThreadPool(THREAD_POOL_SIZE,
                new CustomThreadFactory("ipfs-cache-worker"));

        if (useLocalCache) {
            this.localNode = initializeLocalNode(localNodeUrl, timeout);
        } else {
            this.localNode = null;
        }
    }

    private long validateMaxCacheItems(long maxItems) {
        if (maxItems < 100) {
            throw new IllegalArgumentException("최소 캐시 항목 수는 100입니다");
        }
        return maxItems;
    }

    private IPFS initializeLocalNode(String localNodeUrl, int timeout) {
        try {
            IPFS node = new IPFS(localNodeUrl);
            node.timeout(timeout);
            log.info("IPFS 캐시 관리자 초기화: 최대 캐시 항목 수={}", maxCacheItems);
            return node;
        } catch (Exception e) {
            log.error("IPFS 로컬 노드 초기화 실패", e);
            throw new RuntimeException("IPFS 로컬 노드 초기화 실패", e);
        }
    }

    @PostConstruct
    public void init() {
        if (!useLocalCache) return;

        scheduler.scheduleAtFixedRate(
                () -> {
                    try {
                        cleanupCache();
                    } catch (Exception e) {
                        log.error("캐시 정리 중 오류 발생", e);
                    }
                },
                1, 1, TimeUnit.HOURS
        );
    }

    @PreDestroy
    public void cleanup() {
        shutdownExecutor(scheduler, "스케줄러");
        shutdownExecutor(cacheExecutor, "캐시 실행기");
    }

    private void shutdownExecutor(ExecutorService executor, String name) {
        try {
            executor.shutdown();
            if (!executor.awaitTermination(SHUTDOWN_TIMEOUT_SECONDS, TimeUnit.SECONDS)) {
                executor.shutdownNow();
                if (!executor.awaitTermination(SHUTDOWN_TIMEOUT_SECONDS, TimeUnit.SECONDS)) {
                    log.error("{} 종료 실패", name);
                }
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }

    public void recordAccess(String cid) {
        if (!useLocalCache) return;
        cacheAccessTimes.put(cid, System.currentTimeMillis());
    }

    @Scheduled(fixedDelayString = "${IPFS_CACHE_CLEANUP_INTERVAL:3600000}")
    public void cleanupCache() {
        if (!useLocalCache || localNode == null) return;

        try {
            log.info("IPFS 캐시 정리 시작");
            processCleanup();
        } catch (Exception e) {
            log.error("IPFS 캐시 정리 중 오류 발생", e);
        }
    }

    private void processCleanup() {
        List<Multihash> pinnedItems = getPinnedItems();
        if (pinnedItems == null) return;

        if (pinnedItems.size() <= maxCacheItems) {
            log.info("IPFS 캐시 정리 불필요: 현재={}, 최대={}",
                    pinnedItems.size(), maxCacheItems);
            return;
        }

        removeOldestItems(pinnedItems);
    }

    private List<Multihash> getPinnedItems() {
        try {
            Map<Multihash, Object> pins = localNode.pin.ls();
            return new CopyOnWriteArrayList<>(pins.keySet());
        } catch (Exception e) {
            log.error("핀 목록 조회 실패", e);
            return null;
        }
    }

    private void removeOldestItems(List<Multihash> pinnedItems) {
        int itemsToRemove = calculateItemsToRemove(pinnedItems.size());

        pinnedItems.stream()
                .map(Multihash::toBase58)
                .sorted(this::compareByAccessTime)
                .limit(itemsToRemove)
                .forEach(this::removeItem);

        log.info("IPFS 캐시 정리 완료: {}개 항목 제거됨", itemsToRemove);
    }

    private int calculateItemsToRemove(int currentSize) {
        return (int) Math.ceil((currentSize - maxCacheItems) * 1.2);
    }

    private int compareByAccessTime(String cid1, String cid2) {
        Long time1 = cacheAccessTimes.getOrDefault(cid1, 0L);
        Long time2 = cacheAccessTimes.getOrDefault(cid2, 0L);
        return time1.compareTo(time2);
    }

    private void removeItem(String cid) {
        try {
            Multihash fileMultihash = Multihash.fromBase58(cid);
            localNode.pin.rm(fileMultihash);
            cacheAccessTimes.remove(cid);
            log.info("캐시에서 제거됨: {}", cid);
        } catch (Exception e) {
            log.warn("항목 제거 실패: {}", cid, e);
        }
    }

    @Getter
    @RequiredArgsConstructor
    private static class CustomThreadFactory implements ThreadFactory {
        private final String prefix;
        private final AtomicInteger threadNumber = new AtomicInteger(1);

        @Override
        public Thread newThread(Runnable r) {
            Thread thread = new Thread(r,
                    prefix + "-thread-" + threadNumber.getAndIncrement());
            thread.setDaemon(true);
            return thread;
        }
    }
}