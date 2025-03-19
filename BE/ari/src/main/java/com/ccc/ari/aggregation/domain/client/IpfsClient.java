package com.ccc.ari.aggregation.domain.client;

/**
 * IPFS 연동 인터페이스
 * 데이터를 IPFS에 저장하고 CID를 반환하는 역할을 추상화합니다.
 */
public interface IpfsClient {

    /**
     * 주어진 데이터를 IPFS에 저장하고, 해당 데이터의 CID를 반환한다.
     *
     * @param data 직렬화된 문자열 데이터
     * @return IpfsResponse 객체 (CID값을 포함)
     */
    IpfsResponse save(String data);
}
