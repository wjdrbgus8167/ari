// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract SubscriptionSystem {
    address public owner;
    
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
    
    // 이벤트
    event RegularSubscriptionCreated(uint256 userId, uint256 amount, uint256 interval);
    event RegularSubscriptionCancelled(uint256 userId);
    event ArtistSubscriptionCreated(uint256 subscriberId, uint256 artistId, uint256 amount, uint256 interval);
    event ArtistSubscriptionCancelled(uint256 subscriberId, uint256 artistId);
    event PaymentProcessed(uint256 userId, address tokenAddress, uint256 amount, string subscriptionType);
    event UserRegistered(uint256 userId, address userAddress);
    event ArtistRegistered(uint256 artistId, address artistAddress);
    event SubscriptionSettingsUpdated(uint256 regularAmount, uint256 regularInterval, uint256 artistAmount, uint256 artistInterval, address tokenAddress);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor(
        uint256 _regularAmount,
        uint256 _regularInterval,
        uint256 _artistAmount, 
        uint256 _artistInterval,
        address _tokenAddress
    ) {
        owner = msg.sender;
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
    
    // 정기구독 신청 (금액과 기간은 관리자가 설정한 기본값 사용)
    function subscribeRegular(uint256 userId) external {
        require(userAddresses[userId] == msg.sender, "Only user can subscribe");
        require(defaultRegularAmount > 0, "Subscription amount not set");
        require(defaultRegularInterval > 0, "Subscription interval not set");
        
        // 기존 구독 취소 후 새 구독 생성
        regularSubscriptions[userId] = RegularSubscription({
            startDate: block.timestamp,
            amount: defaultRegularAmount,
            lastPaymentTime: block.timestamp,
            interval: defaultRegularInterval,
            active: true,
            tokenAddress: defaultTokenAddress
        });
        
        // 첫 결제 처리
        IERC20 token = IERC20(defaultTokenAddress);
        require(token.transferFrom(msg.sender, owner, defaultRegularAmount), "Payment failed");
        
        emit RegularSubscriptionCreated(userId, defaultRegularAmount, defaultRegularInterval);
    }
    
    // 정기구독 취소
    function cancelRegularSubscription(uint256 userId) external {
        require(userAddresses[userId] == msg.sender || msg.sender == owner, "Only user or owner can cancel");
        require(regularSubscriptions[userId].active, "No active subscription");
        
        regularSubscriptions[userId].active = false;
        emit RegularSubscriptionCancelled(userId);
    }
    
    // 아티스트 구독 신청 (금액과 기간은 관리자가 설정한 기본값 사용)
    function subscribeToArtist(uint256 subscriberId, uint256 artistId) external {
        require(userAddresses[subscriberId] == msg.sender, "Only subscriber can subscribe");
        require(artistAddresses[artistId] != address(0), "Artist not registered");
        require(defaultArtistAmount > 0, "Subscription amount not set");
        require(defaultArtistInterval > 0, "Subscription interval not set");
        
        // 기존 구독 정보 확인
        if (!artistSubscriptions[subscriberId][artistId].active) {
            // 새 구독이면 구독자 목록에 추가
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
        
        // 첫 결제 처리 (아티스트에게 전송)
        address artistAddress = artistAddresses[artistId];
        IERC20 token = IERC20(defaultTokenAddress);
        require(token.transferFrom(msg.sender, artistAddress, defaultArtistAmount), "Payment failed");
        
        emit ArtistSubscriptionCreated(subscriberId, artistId, defaultArtistAmount, defaultArtistInterval);
    }
    
    // 아티스트 구독 취소
    function cancelArtistSubscription(uint256 subscriberId, uint256 artistId) external {
        require(userAddresses[subscriberId] == msg.sender || msg.sender == owner, "Only subscriber or owner can cancel");
        require(artistSubscriptions[subscriberId][artistId].active, "No active subscription");
        
        artistSubscriptions[subscriberId][artistId].active = false;
        emit ArtistSubscriptionCancelled(subscriberId, artistId);
    }
    
    // 정기구독 결제 처리 (컨트랙트 소유자만 호출 가능)
    function processRegularPayment(uint256 userId) external onlyOwner returns (bool) {
        RegularSubscription storage sub = regularSubscriptions[userId];
        require(sub.active, "Subscription not active");
        
        // 다음 결제 시간인지 확인
        uint256 nextPaymentTime = sub.lastPaymentTime + sub.interval;
        require(block.timestamp >= nextPaymentTime, "Not time for payment yet");
        
        address userAddress = userAddresses[userId];
        
        // 사용자가 충분한 허용액을 설정했는지 확인
        IERC20 token = IERC20(sub.tokenAddress);
        if (token.allowance(userAddress, address(this)) < sub.amount) {
            // 허용액이 부족하면 실패 반환
            return false;
        }
        
        // 결제 처리
        bool success = token.transferFrom(userAddress, owner, sub.amount);
        if (success) {
            sub.lastPaymentTime = block.timestamp;
            emit PaymentProcessed(userId, sub.tokenAddress, sub.amount, "regular");
        }
        
        return success;
    }
    
    // 아티스트 구독 결제 처리 (컨트랙트 소유자만 호출 가능)
    function processArtistPayment(uint256 subscriberId, uint256 artistId) external onlyOwner returns (bool) {
        ArtistSubscription storage sub = artistSubscriptions[subscriberId][artistId];
        require(sub.active, "Subscription not active");
        
        // 다음 결제 시간인지 확인
        uint256 nextPaymentTime = sub.lastPaymentTime + sub.interval;
        require(block.timestamp >= nextPaymentTime, "Not time for payment yet");
        
        address subscriberAddress = userAddresses[subscriberId];
        address artistAddress = artistAddresses[artistId];
        
        // 사용자가 충분한 허용액을 설정했는지 확인
        IERC20 token = IERC20(sub.tokenAddress);
        if (token.allowance(subscriberAddress, address(this)) < sub.amount) {
            // 허용액이 부족하면 실패 반환
            return false;
        }
        
        // 결제 처리
        bool success = token.transferFrom(subscriberAddress, artistAddress, sub.amount);
        if (success) {
            sub.lastPaymentTime = block.timestamp;
            emit PaymentProcessed(subscriberId, sub.tokenAddress, sub.amount, "artist");
        }
        
        return success;
    }
    
    // 정기구독 정보 조회
    function getRegularSubscription(uint256 userId) external view 
    returns (uint256 startDate, uint256 amount, uint256 lastPaymentTime, uint256 nextPaymentTime, bool active, address tokenAddress) {
        RegularSubscription memory sub = regularSubscriptions[userId];
        return (
            sub.startDate,
            sub.amount,
            sub.lastPaymentTime,
            sub.lastPaymentTime + sub.interval,
            sub.active,
            sub.tokenAddress
        );
    }
    
    // 아티스트 구독 정보 조회
    function getArtistSubscription(uint256 subscriberId, uint256 artistId) external view 
    returns (uint256 startDate, uint256 amount, uint256 lastPaymentTime, uint256 nextPaymentTime, bool active, address tokenAddress) {
        ArtistSubscription memory sub = artistSubscriptions[subscriberId][artistId];
        return (
            sub.startDate,
            sub.amount,
            sub.lastPaymentTime,
            sub.lastPaymentTime + sub.interval,
            sub.active,
            sub.tokenAddress
        );
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