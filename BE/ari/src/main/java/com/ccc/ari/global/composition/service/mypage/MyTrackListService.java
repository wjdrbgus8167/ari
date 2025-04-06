
package com.ccc.ari.global.composition.service.mypage;
import com.ccc.ari.aggregation.domain.AggregatedData;
import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.aggregation.infrastructure.adapter.StreamingAggregationContractEventListener;
import com.ccc.ari.global.composition.response.mypage.GetMyTrackListResponse;
import com.ccc.ari.global.contract.StreamingAggregationContract;
import com.ccc.ari.music.domain.album.AlbumDto;
import com.ccc.ari.music.domain.album.client.AlbumClient;
import com.ccc.ari.music.domain.track.TrackDto;
import com.ccc.ari.music.domain.track.client.TrackClient;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

/**
 * 아티스트의 트랙별 스트리밍 횟수를 조회하는 서비스
 * 블록체인에 저장된 아티스트별 집계 데이터를 IPFS를 통해 가져옵니다.
 */
@Service
@RequiredArgsConstructor
public class MyTrackListService {

    private final StreamingAggregationContractEventListener contractEventListener;
    private final IpfsClient ipfsClient;
    private final TrackClient trackClient;
    private final AlbumClient albumClient;

    private final Logger logger = LoggerFactory.getLogger(MyTrackListService.class);

    /**
     * 아티스트(멤버) ID로 해당 아티스트의 모든 트랙에 대한 스트리밍 정보를 조회합니다.
     * 블록체인 이벤트로부터 아티스트별 IPFS CID를 찾아 집계 데이터를 비동기적으로 가져옵니다.
     *
     * @param memberId 아티스트(멤버) ID
     * @return 트랙별 스트리밍 정보 목록 (비동기 응답)
     */
    public CompletableFuture<List<GetMyTrackListResponse>> getArtistTrackStreamingData(Integer memberId) {
        logger.info("아티스트 ID {}의 트랙별 스트리밍 데이터 조회를 시작합니다.", memberId);

        // 1. 블록체인에서 모든 RawArtistTracks 이벤트를 조회
        List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> events =
                contractEventListener.getAllRawAllTracksUpdatedEvents();

        // 2. 최신 아티스트 관련 이벤트 및 CID 찾기
        String latestCid = findLatestArtistCid(memberId, events);

        if (latestCid == null) {
            logger.warn("아티스트 ID {}에 해당하는 집계 데이터를 찾을 수 없습니다.", memberId);
            return CompletableFuture.completedFuture(new ArrayList<>());
        }

        // 3. 비동기로 IPFS에서 집계 데이터 가져오기
        return CompletableFuture.supplyAsync(() -> {
            try {
                logger.info("IPFS에서 CID {}의 집계 데이터를 조회합니다.", latestCid);

                // IPFS에서 집계 데이터 가져오기
                String aggregatedDataJson = ipfsClient.get(latestCid);
                AggregatedData aggregatedData = AggregatedData.fromJson(aggregatedDataJson);

                // 집계 데이터에서 스트리밍 로그 추출
                List<StreamingLog> streamingLogs = aggregatedData.getStreamingLogs();

                // 트랙 ID별 집계
                Map<Integer, Long> totalCountByTrackId = streamingLogs.stream()
                        .collect(Collectors.groupingBy(StreamingLog::getTrackId, Collectors.counting()));

                // 월별 트랙 ID별 집계 (현재 월)
                YearMonth currentYearMonth = YearMonth.now();
                Map<Integer, Long> monthlyCountByTrackId = streamingLogs.stream()
                        .filter(log -> {
                            LocalDateTime logTime = log.getTimestamp().atZone(ZoneId.systemDefault()).toLocalDateTime();
                            return YearMonth.from(logTime).equals(currentYearMonth);
                        })
                        .collect(Collectors.groupingBy(StreamingLog::getTrackId, Collectors.counting()));

                // 4. 아티스트의 모든 앨범 정보 가져오기
                List<AlbumDto> albumDtoList = albumClient.getAllAlbumsByMember(memberId);

                // 5. 각 앨범별 트랙 정보와 스트리밍 데이터 연결
                List<GetMyTrackListResponse> responses = new ArrayList<>();

                for (AlbumDto albumDto : albumDtoList) {
                    // 앨범의 모든 트랙 조회
                    List<TrackDto> trackDtoList = trackClient.getTracksByAlbumId(albumDto.getAlbumId());

                    for (TrackDto trackDto : trackDtoList) {
                        Integer trackId = trackDto.getTrackId();

                        // 트랙별 전체 스트리밍 횟수
                        long totalCount = totalCountByTrackId.getOrDefault(trackId, 0L);

                        // 트랙별 월간 스트리밍 횟수
                        long monthlyCount = monthlyCountByTrackId.getOrDefault(trackId, 0L);

                        // 응답 객체 생성
                        GetMyTrackListResponse response = GetMyTrackListResponse.builder()
                                .trackTitle(trackDto.getTitle())
                                .coverImageUrl(albumDto.getCoverImageUrl()) // 앨범 커버 이미지 URL
                                .monthlyStreamingCount(String.valueOf(monthlyCount))
                                .totalStreamingCount(String.valueOf(totalCount))
                                .build();

                        responses.add(response);
                    }
                }

                logger.info("아티스트 ID {}의 트랙별 스트리밍 데이터 조회가 완료되었습니다. {}개의 트랙 정보를 반환합니다.",
                        memberId, responses.size());
                return responses;

            } catch (Exception e) {
                logger.error("아티스트 트랙 스트리밍 데이터 조회 중 오류 발생", e);
                return new ArrayList<>();
            }
        });
    }

    /**
     * 특정 트랜잭션 해시로부터 아티스트의 트랙별 스트리밍 정보를 조회합니다.
     *
     * @param txHash 트랜잭션 해시
     * @param memberId 아티스트(멤버) ID
     * @return 트랙별 스트리밍 정보 목록 (비동기 응답)
     */
    public CompletableFuture<List<GetMyTrackListResponse>> getArtistTrackStreamingDataByTxHash(
            String txHash, Integer memberId) {
        logger.info("트랜잭션 해시 {}로부터 아티스트 ID {}의 트랙별 스트리밍 데이터 조회를 시작합니다.", txHash, memberId);

        // 트랜잭션 해시로 이벤트 조회
        List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> events =
                contractEventListener.getRawAllTracksUpdatedEventsByTxHash(txHash);

        if (events.isEmpty()) {
            logger.warn("트랜잭션 해시 {}에 해당하는 이벤트를 찾을 수 없습니다.", txHash);
            return CompletableFuture.completedFuture(new ArrayList<>());
        }

        // 이벤트에서 CID 추출
        String cid = events.get(0).cid;

        // 비동기로 IPFS에서 집계 데이터 가져오기
        return CompletableFuture.supplyAsync(() -> {
            try {
                logger.info("IPFS에서 CID {}의 집계 데이터를 조회합니다.", cid);

                // IPFS에서 집계 데이터 가져오기
                String aggregatedDataJson = ipfsClient.get(cid);
                AggregatedData aggregatedData = AggregatedData.fromJson(aggregatedDataJson);

                // 집계 데이터에서 스트리밍 로그 추출
                List<StreamingLog> streamingLogs = aggregatedData.getStreamingLogs();

                // 트랙 ID별 집계
                Map<Integer, Long> totalCountByTrackId = streamingLogs.stream()
                        .collect(Collectors.groupingBy(StreamingLog::getTrackId, Collectors.counting()));

                // 월별 트랙 ID별 집계 (현재 월)
                YearMonth currentYearMonth = YearMonth.now();
                Map<Integer, Long> monthlyCountByTrackId = streamingLogs.stream()
                        .filter(log -> {
                            LocalDateTime logTime = log.getTimestamp().atZone(ZoneId.systemDefault()).toLocalDateTime();
                            return YearMonth.from(logTime).equals(currentYearMonth);
                        })
                        .collect(Collectors.groupingBy(StreamingLog::getTrackId, Collectors.counting()));

                // 아티스트의 모든 앨범 정보 가져오기
                List<AlbumDto> albumDtoList = albumClient.getAllAlbumsByMember(memberId);

                // 각 앨범별 트랙 정보와 스트리밍 데이터 연결
                List<GetMyTrackListResponse> responses = new ArrayList<>();

                for (AlbumDto albumDto : albumDtoList) {
                    // 앨범의 모든 트랙 조회
                    List<TrackDto> trackDtoList = trackClient.getTracksByAlbumId(albumDto.getAlbumId());

                    for (TrackDto trackDto : trackDtoList) {
                        Integer trackId = trackDto.getTrackId();

                        // 트랙별 전체 스트리밍 횟수
                        long totalCount = totalCountByTrackId.getOrDefault(trackId, 0L);

                        // 트랙별 월간 스트리밍 횟수
                        long monthlyCount = monthlyCountByTrackId.getOrDefault(trackId, 0L);

                        // 응답 객체 생성
                        GetMyTrackListResponse response = GetMyTrackListResponse.builder()
                                .trackTitle(trackDto.getTitle())
                                .coverImageUrl(albumDto.getCoverImageUrl()) // 앨범 커버 이미지 URL
                                .monthlyStreamingCount(String.valueOf(monthlyCount))
                                .totalStreamingCount(String.valueOf(totalCount))
                                .build();

                        responses.add(response);
                    }
                }

                logger.info("트랜잭션 해시 {}로부터 아티스트 ID {}의 트랙별 스트리밍 데이터 조회가 완료되었습니다.",
                        txHash, memberId);
                return responses;

            } catch (Exception e) {
                logger.error("트랜잭션 해시로부터 아티스트 트랙 스트리밍 데이터 조회 중 오류 발생", e);
                return new ArrayList<>();
            }
        });
    }

    /**
     * 블록체인 이벤트 중 해당 아티스트 ID에 대한 최신 CID를 찾습니다.
     *
     * @param artistId 아티스트 ID
     * @param events 블록체인 이벤트 목록
     * @return 최신 IPFS CID 또는 null
     */
    private String findLatestArtistCid(Integer artistId, List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> events) {
        // 이벤트가 없는 경우
        if (events.isEmpty()) {
            return null;
        }

        // 아티스트 ID에 해당하는 이벤트 찾기
        List<StreamingAggregationContract.RawAllTracksUpdatedEventResponse> artistEvents = new ArrayList<>();

        for (StreamingAggregationContract.RawAllTracksUpdatedEventResponse event : events) {
            try {
                // CID로 데이터를 가져와서 아티스트 ID 확인
                String aggregatedDataJson = ipfsClient.get(event.cid);
                AggregatedData aggregatedData = AggregatedData.fromJson(aggregatedDataJson);

                // 해당 아티스트의 스트리밍 로그가 있는지 확인
                boolean containsArtistData = aggregatedData.getStreamingLogs().stream()
                        .anyMatch(log -> log.getArtistId() != null && log.getArtistId().equals(artistId));

                if (containsArtistData) {
                    artistEvents.add(event);
                }
            } catch (Exception e) {
                logger.warn("CID {}의 데이터 확인 중 오류 발생", event.cid, e);
            }
        }

        if (artistEvents.isEmpty()) {
            return null;
        }

        // 가장 최신 이벤트 찾기 (블록넘버가 높은 것)
        StreamingAggregationContract.RawAllTracksUpdatedEventResponse latestEvent = artistEvents.get(0);
        for (StreamingAggregationContract.RawAllTracksUpdatedEventResponse event : artistEvents) {
            // 블록넘버 비교 (높은 것이 최신)
            if (event.log.getBlockNumber().compareTo(latestEvent.log.getBlockNumber()) > 0) {
                latestEvent = event;
            }
        }

        return latestEvent.cid;
    }
}