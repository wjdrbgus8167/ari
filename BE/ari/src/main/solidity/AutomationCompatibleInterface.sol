// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AutomationCompatibleInterface {
    /**
     * @notice 체인링크 오토메이션이 업킵이 필요한지 확인하기 위해 호출하는 메서드
     * @param checkData 체크용으로 전달되는 바이트 데이터
     * @return upkeepNeeded 업킵이 필요한지 여부, performData 업킵을 수행할 때 사용할 데이터
     */
    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData);

    /**
     * @notice 체인링크 오토메이션이 업킵을 수행하기 위해 호출하는 메서드
     * @param performData checkUpkeep에서 반환된 데이터
     */
    function performUpkeep(bytes calldata performData) external;
}