// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Ownable 및 SafeERC20 사용
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SubscriptionContract is Ownable {
    using SafeERC20 for IERC20;

    struct RegularSubscription {
        uint256 startDate;       // 구독 시작일
        uint256 amount;          // 매달 청구할 금액
        uint256 lastPaymentTime; // 마지막 결제 시간
        uint256 interval;        // 결제 간격(초 단위, 보통 30일)
        bool active;             // 구독 활성화 상태
        address tokenAddress;    // 결제에 사용할 토큰 컨트랙트 주소
    }

    // 아티스트 구독 구조체
    struct ArtistSubscription {
        uint256 startDate;       // 구독 시작일
        uint256 amount;          // 매달 청구할 금액
        uint256 lastPaymentTime; // 마지막 결제 시간
        uint256 interval;        // 결제 간격
        bool active;             // 구독 활성화 상태
        address tokenAddress;    // 결제에 사용할 토큰 컨트랙트 주소
    }

    // 기본 구독 금액 및 기간 (관리자만 설정 가능)
    uint256 public defaultRegularAmount;
    uint256 public defaultRegularInterval;
    uint256 public defaultArtistAmount;
    uint256 public defaultArtistInterval;
    address public defaultTokenAddress;

    // 사용자 ID => 정기구독 정보
    mapping(uint256 => RegularSubscription) public regularSubscriptions;

    // 구독자 ID => 아티스트 ID => 아티스트 구독 정보
    mapping(uint256 => mapping(uint256 => ArtistSubscription)) public artistSubscriptions;

    // 사용자 ID => 사용자 주소
    mapping(uint256 => address) public userAddresses;

    // 사용자 주소 => 사용자 ID
    mapping(address => uint256) public addressToUserId;

    // 아티스트 ID => 아티스트 주소
    mapping(uint256 => address) public artistAddresses;

    // 각 아티스트를 구독한 구독자 ID 목록
    mapping(uint256 => uint256[]) public artistSubscribers;

    // 각 사용자가 구독한 아티스트 ID 목록
    mapping(uint256 => uint256[]) public userSubscribedArtists;

    // 기본 이벤트들
    event RegularSubscriptionCreated(uint256 userId, uint256 amount, uint256 interval);
    event RegularSubscriptionCancelled(uint256 userId);
    event ArtistSubscriptionCreated(uint256 subscriberId, uint256 artistId, uint256 amount, uint256 interval);
    event ArtistSubscriptionCancelled(uint256 subscriberId, uint256 artistId);
    event PaymentProcessed(uint256 userId, address tokenAddress, uint256 amount, string subscriptionType);
    event UserRegistered(uint256 userId, address userAddress);
    event ArtistRegistered(uint256 artistId, address artistAddress);
    event SubscriptionSettingsUpdated(uint256 regularAmount, uint256 regularInterval, uint256 artistAmount, uint256 artistInterval, address tokenAddress);

    // 정산 관련 이벤트
    event SettlementRequestedRegular(uint256 indexed userId, uint256 periodStart, uint256 periodEnd, uint256 amount);
    event SettlementRequestedArtist(uint256 indexed artistId, uint256 subscriberId, uint256 periodStart, uint256 periodEnd, uint256 amount);
    event SettlementExecuted(uint256 userId, uint256 indexed artistId, uint256 subscriberId, uint256 amount, string ipfsCID);

    constructor(
        uint256 _regularAmount,
        uint256 _regularInterval,
        uint256 _artistAmount,
        uint256 _artistInterval,
        address _tokenAddress
    ) Ownable(msg.sender) {
        defaultRegularAmount = _regularAmount;
        defaultRegularInterval = _regularInterval;
        defaultArtistAmount = _artistAmount;
        defaultArtistInterval = _artistInterval;
        defaultTokenAddress = _tokenAddress;
    }

    // 관리자가 구독 설정 업데이트
    function updateSubscriptionSettings(
        uint256 _regularAmount,
        uint256 _regularInterval,
        uint256 _artistAmount,
        uint256 _artistInterval,
        address _tokenAddress
    ) external onlyOwner {
        defaultRegularAmount = _regularAmount;
        defaultRegularInterval = _regularInterval;
        defaultArtistAmount = _artistAmount;
        defaultArtistInterval = _artistInterval;
        defaultTokenAddress = _tokenAddress;

        emit SubscriptionSettingsUpdated(_regularAmount, _regularInterval, _artistAmount, _artistInterval, _tokenAddress);
    }

    // 사용자 등록
    function registerUser(uint256 userId) external {
        require(addressToUserId[msg.sender] == 0, "Address already registered");
        require(userAddresses[userId] == address(0), "User ID already taken");

        userAddresses[userId] = msg.sender;
        addressToUserId[msg.sender] = userId;

        emit UserRegistered(userId, msg.sender);
    }

    // 아티스트 등록
    function registerArtist(uint256 artistId) external {
        require(artistAddresses[artistId] == address(0), "Artist ID already taken");

        artistAddresses[artistId] = msg.sender;

        emit ArtistRegistered(artistId, msg.sender);
    }

    // 정기구독 신청 (관리자 설정 기본값 사용)
    // 결제 시 토큰은 owner가 아닌 컨트랙트로 송금됨
    function subscribeRegular(uint256 userId) external {
        require(userAddresses[userId] == msg.sender, "Only user can subscribe");
        require(defaultRegularAmount > 0, "Subscription amount not set");
        require(defaultRegularInterval > 0, "Subscription interval not set");

        // 기존 구독은 덮어씌움
        regularSubscriptions[userId] = RegularSubscription({
            startDate: block.timestamp,
            amount: defaultRegularAmount,
            lastPaymentTime: block.timestamp,
            interval: defaultRegularInterval,
            active: true,
            tokenAddress: defaultTokenAddress
        });

        // 첫 결제 처리: 사용자의 토큰을 컨트랙트로 송금
        IERC20(defaultTokenAddress).safeTransferFrom(msg.sender, address(this), defaultRegularAmount);

        emit RegularSubscriptionCreated(userId, defaultRegularAmount, defaultRegularInterval);
    }

    // 아티스트 구독 신청 (관리자 설정 기본값 사용)
    // 결제 시 토큰은 컨트랙트로 송금됨
    function subscribeToArtist(uint256 subscriberId, uint256 artistId) external {
        require(userAddresses[subscriberId] == msg.sender, "Only subscriber can subscribe");
        require(artistAddresses[artistId] != address(0), "Artist not registered");
        require(defaultArtistAmount > 0, "Subscription amount not set");
        require(defaultArtistInterval > 0, "Subscription interval not set");

        // 신규 구독인 경우에만 배열에 추가
        if (!artistSubscriptions[subscriberId][artistId].active) {
            artistSubscribers[artistId].push(subscriberId);
            userSubscribedArtists[subscriberId].push(artistId);
        }

        // 구독 정보 업데이트
        artistSubscriptions[subscriberId][artistId] = ArtistSubscription({
            startDate: block.timestamp,
            amount: defaultArtistAmount,
            lastPaymentTime: block.timestamp,
            interval: defaultArtistInterval,
            active: true,
            tokenAddress: defaultTokenAddress
        });

        // 첫 결제 처리: 사용자의 토큰을 컨트랙트로 송금
        IERC20(defaultTokenAddress).safeTransferFrom(msg.sender, address(this), defaultArtistAmount);

        emit ArtistSubscriptionCreated(subscriberId, artistId, defaultArtistAmount, defaultArtistInterval);
    }

    // 정기구독 취소
    function cancelRegularSubscription(uint256 userId) external {
        require(userAddresses[userId] == msg.sender || msg.sender == owner(), "Only user or owner can cancel");
        require(regularSubscriptions[userId].active, "No active subscription");

        regularSubscriptions[userId].active = false;
        emit RegularSubscriptionCancelled(userId);
    }

    // 아티스트 구독 취소: 취소 시 관련 배열에서 해당 구독 정보를 제거
    function cancelArtistSubscription(uint256 subscriberId, uint256 artistId) external {
        require(userAddresses[subscriberId] == msg.sender || msg.sender == owner(), "Only subscriber or owner can cancel");
        require(artistSubscriptions[subscriberId][artistId].active, "No active subscription");

        artistSubscriptions[subscriberId][artistId].active = false;

        // artistSubscribers 배열에서 subscriberId 제거
        _removeFromArray(artistSubscribers[artistId], subscriberId);
        // userSubscribedArtists 배열에서 artistId 제거
        _removeFromArray(userSubscribedArtists[subscriberId], artistId);

        emit ArtistSubscriptionCancelled(subscriberId, artistId);
    }

    // 정기구독 결제 처리
    // 체인링크 Keepers 등이 조건을 감시하여 호출할 수 있도록 onlyOwner 제한을 제거
    function processRegularPayment(uint256 userId) external returns (bool) {
        RegularSubscription storage sub = regularSubscriptions[userId];
        require(sub.active, "Subscription not active");

        // 다음 결제 시간인지 확인
        uint256 nextPaymentTime = sub.lastPaymentTime + sub.interval;
        require(block.timestamp >= nextPaymentTime, "Not time for payment yet");

        // 결제 전, 구독 기간에 대한 정산 요청 이벤트 발생
        emit SettlementRequestedRegular(userId, sub.lastPaymentTime, nextPaymentTime, sub.amount);

        // 새 결제 처리: 사용자의 토큰을 컨트랙트로 송금
        IERC20(sub.tokenAddress).safeTransferFrom(userAddresses[userId], address(this), sub.amount);

        sub.lastPaymentTime = block.timestamp;
        emit PaymentProcessed(userId, sub.tokenAddress, sub.amount, "regular");
        return true;
    }

    // 아티스트 구독 결제 처리
    function processArtistPayment(uint256 subscriberId, uint256 artistId) external returns (bool) {
        ArtistSubscription storage sub = artistSubscriptions[subscriberId][artistId];
        require(sub.active, "Subscription not active");

        // 다음 결제 시간인지 확인
        uint256 nextPaymentTime = sub.lastPaymentTime + sub.interval;
        require(block.timestamp >= nextPaymentTime, "Not time for payment yet");

        // 정산 요청 이벤트 발생
        emit SettlementRequestedArtist(artistId, subscriberId, sub.lastPaymentTime, nextPaymentTime, sub.amount);

        // 새 결제 처리: 사용자의 토큰을 컨트랙트로 송금
        IERC20(sub.tokenAddress).safeTransferFrom(userAddresses[subscriberId], address(this), sub.amount);

        sub.lastPaymentTime = block.timestamp;
        emit PaymentProcessed(subscriberId, sub.tokenAddress, sub.amount, "artist");
        return true;
    }

    // 정산 함수: 오프체인에서 전달받은 아티스트 별 스트리밍 횟수 데이터를 사용하여
    // 컨트랙트에 보관 중인 해당 구독자의 결제 토큰을 분배합니다.
    // 전달 파라미터: artistIds와 streamingCounts 배열은 각각 아티스트 ID와 해당 아티스트의 스트리밍 횟수를 나타냅니다.
    // 예를 들어, artistIds: [1, 2, 3] 그리고 streamingCounts: [20, 60, 120] 이런 식으로 전달하면
    // 함수 내부에서 총 스트리밍 횟수(200)를 계산한 후, 각 아티스트의 비율(20/200, 60/200, 120/200)을 산출하여 분배합니다.
    function settleArtistPayments(
        uint256 subscriberId,
        uint256 totalAmount, // 정산할 총 금액
        uint256[] calldata artistIds,
        uint256[] calldata streamingCounts, // 각 아티스트의 스트리밍 횟수
        string calldata ipfsCID
    ) external onlyOwner returns (bool) {
        require(artistIds.length == streamingCounts.length, "Mismatched array lengths");

        // 플랫폼 몫: 전체 금액의 10%
        uint256 platformShare = (totalAmount * 10) / 100;
        // 아티스트에게 분배할 총액은 전체 금액에서 플랫폼 몫을 뺀 금액
        uint256 distributable = totalAmount - platformShare;
        uint256 totalStreaming = _getTotalStreaming(streamingCounts);
        require(totalStreaming > 0, "No streaming counts provided");

        for (uint256 i = 0; i < artistIds.length; i++) {
            address artistAddr = artistAddresses[artistIds[i]];
            require(artistAddr != address(0), "Artist not registered");
            // 각 아티스트에게 지급할 금액 = distributable * (해당 아티스트 스트리밍 횟수) / (전체 스트리밍 횟수)
            uint256 payout = (distributable * streamingCounts[i]) / totalStreaming;
            IERC20(defaultTokenAddress).safeTransfer(artistAddr, payout);
            _emitSettlementExecuted(subscriberId, artistIds[i], payout, ipfsCID);
        }

        // 플랫폼 몫을 소유자(플랫폼)에게 송금
        IERC20(defaultTokenAddress).safeTransfer(owner(), platformShare);
        return true;
    }

    // 헬퍼 함수: 전달받은 스트리밍 횟수 배열의 총합 계산
    function _getTotalStreaming(uint256[] calldata streamingCounts) internal pure returns (uint256 sum) {
        for (uint256 i = 0; i < streamingCounts.length; i++) {
            sum += streamingCounts[i];
        }
    }

    // 헬퍼 함수: 배열에서 특정 값을 제거
    function _removeFromArray(uint256[] storage array, uint256 value) internal {
        uint256 length = array.length;
        for (uint256 i = 0; i < length; i++) {
            if (array[i] == value) {
                array[i] = array[length - 1];
                array.pop();
                break;
            }
        }
    }

    // 헬퍼 함수: SettlementExecuted 이벤트를 emit (Stack too deep 완화)
    function _emitSettlementExecuted(
        uint256 subscriberId,
        uint256 artistId,
        uint256 payout,
        string calldata ipfsCID
    ) internal {
        emit SettlementExecuted(subscriberId, artistId, subscriberId, payout, ipfsCID);
    }

    // 정기구독 정보 조회
    function getRegularSubscription(uint256 userId) external view returns (
        uint256 startDate,
        uint256 amount,
        uint256 lastPaymentTime,
        uint256 nextPaymentTime,
        bool active,
        address tokenAddress
    ) {
        RegularSubscription memory sub = regularSubscriptions[userId];
        return (sub.startDate, sub.amount, sub.lastPaymentTime, sub.lastPaymentTime + sub.interval, sub.active, sub.tokenAddress);
    }

    // 아티스트 구독 정보 조회
    function getArtistSubscription(uint256 subscriberId, uint256 artistId) external view returns (
        uint256 startDate,
        uint256 amount,
        uint256 lastPaymentTime,
        uint256 nextPaymentTime,
        bool active,
        address tokenAddress
    ) {
        ArtistSubscription memory sub = artistSubscriptions[subscriberId][artistId];
        return (sub.startDate, sub.amount, sub.lastPaymentTime, sub.lastPaymentTime + sub.interval, sub.active, sub.tokenAddress);
    }

    // 특정 아티스트의 구독자 수 조회
    function getArtistSubscriberCount(uint256 artistId) external view returns (uint256) {
        return artistSubscribers[artistId].length;
    }

    // 특정 아티스트의 구독자 ID 목록 조회
    function getArtistSubscribers(uint256 artistId) external view returns (uint256[] memory) {
        return artistSubscribers[artistId];
    }

    // 특정 사용자가 구독한 아티스트 수 조회
    function getUserSubscribedArtistCount(uint256 userId) external view returns (uint256) {
        return userSubscribedArtists[userId].length;
    }

    // 특정 사용자가 구독한 아티스트 ID 목록 조회
    function getUserSubscribedArtists(uint256 userId) external view returns (uint256[] memory) {
        return userSubscribedArtists[userId];
    }

    // 사용자 주소로 사용자 ID 조회
    function getUserIdByAddress(address userAddress) external view returns (uint256) {
        return addressToUserId[userAddress];
    }

    // 아티스트 ID로 아티스트 주소 조회
    function getArtistAddressById(uint256 artistId) external view returns (address) {
        return artistAddresses[artistId];
    }
}
