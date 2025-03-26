// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract StreamingAggregationContract is Ownable {

    // 전체 스트리밍 집계 이벤트: 배치 타임스탬프와 IPFS CID 기록
    event RawAllTracksUpdated(
        uint256 indexed batchTimestamp,
        string cid
    );

    // 장르별 스트리밍 집계 이벤트: 배치 타임스탬프, 장르 ID, IPFS CID 기록
    event RawGenreTracksUpdated(
        uint256 indexed batchTimestamp,
        bytes32 indexed genreId,
        string cid
    );

    // 아티스트별 스트리밍 집계 이벤트: 배치 타임스탬프, 아티스트 ID, IPFS CID 기록
    event RawArtistTracksUpdated(
        uint256 indexed batchTimestamp,
        bytes32 indexed artistId,
        string cid
    );

    // 리스너별 스트리밍 집계 이벤트: 배치 타임스탬프, 리스너 ID, IPFS CID 기록
    event RawListenerTracksUpdated(
        uint256 indexed batchTimestamp,
        bytes32 indexed listenerId,
        string cid
    );

    /**
     * @notice 전체 스트리밍 집계 데이터를 커밋합니다.
     * @param cid IPFS에 저장된 전체 집계 데이터의 CID
     */
    function commitRawAllTracks(string calldata cid) external onlyOwner {
        emit RawAllTracksUpdated(block.timestamp, cid);
    }

    /**
     * @notice 장르별 스트리밍 집계 데이터를 커밋합니다.
     * @param genreId 집계 대상 장르의 ID (bytes32 형식)
     * @param cid IPFS에 저장된 장르별 집계 데이터의 CID
     */
    function commitRawGenreTracks(bytes32 genreId, string calldata cid) external onlyOwner {
        emit RawGenreTracksUpdated(block.timestamp, genreId, cid);
    }

    /**
     * @notice 아티스트별 스트리밍 집계 데이터를 커밋합니다.
     * @param artistId 집계 대상 아티스트의 ID (bytes32 형식)
     * @param cid IPFS에 저장된 아티스트별 집계 데이터의 CID
     */
    function commitRawArtistTracks(bytes32 artistId, string calldata cid) external onlyOwner {
        emit RawArtistTracksUpdated(block.timestamp, artistId, cid);
    }

    /**
     * @notice 리스너별 스트리밍 집계 데이터를 커밋합니다.
     * @param listenerId 집계 대상 리스너의 ID (bytes32 형식)
     * @param cid IPFS에 저장된 리스너별 집계 데이터의 CID
     */
    function commitRawListenerTracks(bytes32 listenerId, string calldata cid) external onlyOwner {
        emit RawListenerTracksUpdated(block.timestamp, listenerId, cid);
    }

    /**
     * @notice Initialize with a specified admin.
     */
    constructor() Ownable(msg.sender) {
        // The msg.sender will be set as the owner of this smart-contract 
    }
}
