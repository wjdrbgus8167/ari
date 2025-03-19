package com.ccc.ari.aggregation.domain.client;

/**
 * 블록체인 연동 인터페이스
 * IPFS에 저장된 데이터의 CID를 스마트 컨트랙트에 커밋하는 역할을 추상화합니다.
 */
public interface BlockChainClient {
    /**
     * 주어진 CID와 머클 루트를 블록체인에 커밋한다.
     *
     * @param cid IPFS에서 반환된 CID
     * @return 트랜잭션 해시 혹은 커밋 결과 식별자
     */
    String commitAggregatedData(String cid);
}
