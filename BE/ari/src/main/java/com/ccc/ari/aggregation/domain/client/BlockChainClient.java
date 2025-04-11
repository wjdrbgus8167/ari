package com.ccc.ari.aggregation.domain.client;

/**
 * 블록체인 연동 인터페이스
 * IPFS에 저장된 데이터의 CID를 스마트 컨트랙트에 커밋하는 역할을 추상화합니다.
 */
public interface BlockChainClient {
    /**
     * 전체 트랙에 대한 스트리밍 로그가 위치한 CID를 블록체인에 커밋한다.
     *
     * @param cid IPFS에서 반환된 CID
     * @return 트랜잭션 해시 혹은 커밋 결과 식별자
     */
    String commitRawAllTracks(String cid);

    /**
     * 장르별 스트리밍 로그가 위치한 CID를 블록체인에 커밋한다.
     *
     * @param genreId 해당 장르의 ID
     * @param cid IPFS에서 반환된 CID
     * @return 트랜잭션 해시 혹은 커밋 결과 식별자
     */
    String commitRawGenreTracks(Integer genreId, String cid);

    /**
     * 아티스트별 스트리밍 로그가 위치한 CID를 블록체인에 커밋한다.
     *
     * @param artistId 해당 아티스트의 ID
     * @param cid IPFS에서 반환된 CID
     * @return 트랜잭션 해시 혹은 커밋 결과 식별자
     */
    String commitRawArtistTracks(Integer artistId, String cid);

    /**
     * 리스너별 스트리밍 로그가 위치한 CID를 블록체인에 커밋한다.
     *
     * @param listenerId 해당 리스너의 ID
     * @param cid IPFS에서 반환된 CID
     * @return 트랜잭션 해시 혹은 커밋 결과 식별자
     */
    String commitRawListenerTracks(Integer listenerId, String cid);
}
