import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:developer' as dev;

// 외부에서 사용할 트랜잭션 상태와 결과를 위한 콜백 타입 정의
typedef TransactionCallback =
    void Function(String? txHash, bool success, String? errorMessage);

/// 지갑 연결 및 트랜잭션 관련 기능을 제공하는 서비스 클래스
class WalletService extends ChangeNotifier {
  // 싱글톤 패턴
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  // 앱킷 모달 인스턴스 - late 대신 nullable로 변경
  ReownAppKitModal? _appKitModal;

  // 상태값
  String? _address;
  bool _isTransferring = false;
  String? _lastTxHash;
  bool _isInitialized = false;

  // LINK 토큰 주소 매핑 (네트워크별)
  final Map<String, String> linkTokenAddresses = {
    'eip155:1': '0x514910771AF9Ca656af840dff83E8264EcF986CA', // 이더리움 메인넷
    'eip155:11155111':
        '0x779877A7B0D9E8603169DdbD7836e478b4624789', // Sepolia 테스트넷
    'eip155:137': '0xb0897686c545045aFc77CF20eC7A532E3120E0F1', // Polygon 메인넷
  };

  // 지원되는 체인 ID
  final String ethereumChainId = "eip155:1"; // 이더리움 메인넷
  final String sepoliaChainId = "eip155:11155111"; // Sepolia 테스트넷
  final String polygonChainId = "eip155:137"; // Polygon 메인넷

  // 구독 컨트랙트 주소 (네트워크별)
  final Map<String, String> subscriptionContractAddresses = {
    'eip155:1': '0xSubscriptionContractAddressOnEthereum', // 이더리움 메인넷
    'eip155:11155111':
        '0x59ebe02e4cb4c9f1b3dbb2e2ae9a4ee56926cfef', // Sepolia 테스트넷
    'eip155:137': '0xSubscriptionContractAddressOnPolygon', // Polygon 메인넷
  };

  /// 현재 선택된 네트워크의 LINK 토큰 주소를 반환합니다.
  String getCurrentLinkTokenAddress() {
    if (_appKitModal == null || _appKitModal!.selectedChain == null) {
      return linkTokenAddresses[sepoliaChainId] ?? ''; // 기본값으로 Sepolia 사용
    }

    final chainId = _appKitModal!.selectedChain!.chainId;
    return linkTokenAddresses[chainId] ?? '';
  }

  /// 현재 선택된 네트워크의 구독 컨트랙트 주소를 반환합니다.
  String getCurrentSubscriptionContractAddress() {
    if (_appKitModal == null || _appKitModal!.selectedChain == null) {
      return subscriptionContractAddresses[sepoliaChainId] ??
          ''; // 기본값으로 Sepolia 사용
    }

    final chainId = _appKitModal!.selectedChain!.chainId;
    return subscriptionContractAddresses[chainId] ?? '';
  }

  /// 지원 네트워크 설정
  @override
  void _setupSupportedNetworks() {
    // 기존 네트워크 제거
    ReownAppKitModalNetworks.removeSupportedNetworks('solana');
    ReownAppKitModalNetworks.removeSupportedNetworks('polkadot');
    ReownAppKitModalNetworks.removeSupportedNetworks('tron');
    ReownAppKitModalNetworks.removeSupportedNetworks('mvx');

    // 이더리움, Sepolia, Polygon만 사용하도록 다른 EVM 체인 제거
    final supportedEVMChains = [
      '1',
      '11155111',
      '137',
    ]; // 이더리움, Sepolia, Polygon

    final allEVMChains = ReownAppKitModalNetworks.getAllSupportedNetworks(
      namespace: 'eip155',
    );
    for (final chain in allEVMChains) {
      final chainNumber = chain.chainId.split(':').last;
      if (!supportedEVMChains.contains(chainNumber)) {
        ReownAppKitModalNetworks.removeSupportedNetworks('eip155:$chainNumber');
      }
    }

    dev.log("[WalletService] 네트워크 설정 완료: 이더리움, Sepolia, Polygon만 지원");
  }

  // Getters
  String get address => _address ?? "none";
  bool get isTransferring => _isTransferring;
  String? get lastTxHash => _lastTxHash;
  bool get isConnected => _isInitialized && _appKitModal?.isConnected == true;
  bool get isInitialized => _isInitialized;

  // appKitModal getter
  ReownAppKitModal get appKitModal {
    if (_appKitModal == null) {
      throw Exception('WalletService가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return _appKitModal!;
  }

  /// 이벤트 핸들러를 위한 콜백 정의
  Function(void)? onConnect;
  Function(void)? onDisconnect;
  Function(void)? onUpdate;
  Function(void)? onNetworkChange;

  /// 지갑 서비스 초기화
  void initialize(BuildContext context) {
    if (_isInitialized) return;

    dev.log("[WalletService] 초기화 시작");

    _appKitModal = ReownAppKitModal(
      context: context,
      projectId: '8d9043fa458c3dbd6c29cb76c7db4c4a',
      metadata: const PairingMetadata(
        name: 'Ari',
        description: 'Ari app description',
        url: 'https://example.com/',
        icons: ['https://example.com/logo.png'],
        redirect: Redirect(
          native: 'ari://',
          universal: 'https://reown.com/exampleapp',
          linkMode: true,
        ),
      ),
    );

    // 이벤트 리스너 등록
    _appKitModal!.onModalConnect.subscribe(_onModalConnect);
    _appKitModal!.onModalUpdate.subscribe(_onModalUpdate);
    _appKitModal!.onModalNetworkChange.subscribe(_onModalNetworkChange);
    _appKitModal!.onModalDisconnect.subscribe(_onModalDisconnect);
    _appKitModal!.onModalError.subscribe(_onModalError);

    dev.log("[WalletService] 이벤트 리스너 등록 완료");

    // 네트워크 설정
    _setupSupportedNetworks();

    // 앱킷 초기화
    _appKitModal!.init();

    _isInitialized = true;
    dev.log("[WalletService] 초기화 완료");
  }

  /// 주소 업데이트
  void _updateAddress() {
    _address = _appKitModal?.session?.getAddress(
      NamespaceUtils.getNamespaceFromChain(
        _appKitModal?.selectedChain?.chainId ?? "1",
      ),
    );
  }

  /// 연결 해제
  void disconnect() {
    if (isConnected) {
      _appKitModal?.disconnect();
      notifyListeners();
    }
  }

  // 모달 이벤트 핸들러
  void _onModalConnect(ModalConnect? event) {
    dev.log('[WalletService] _onModalConnect ${event?.session.toJson()}');
    _updateAddress();
    onConnect?.call(null);
    notifyListeners();
    print("전달했을듯");
  }

  void _onModalUpdate(ModalConnect? event) {
    dev.log('[WalletService] _onModalUpdate ${event?.session.toJson()}');
    _updateAddress();
    onUpdate?.call(null);
    notifyListeners();
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    dev.log('[WalletService] _onModalNetworkChange ${event?.toString()}');
    _updateAddress();
    onNetworkChange?.call(null);
    notifyListeners();
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    dev.log('[WalletService] _onModalDisconnect ${event?.toString()}');
    _address = "none";
    _isTransferring = false;
    onDisconnect?.call(null);
    notifyListeners();
  }

  void _onModalError(ModalError? event) {
    dev.log('[WalletService] _onModalError ${event?.toString()}');

    // Coinbase Wallet 오류 처리 (지갑에서 직접 연결 해제한 경우)
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      _appKitModal?.disconnect();
    }
  }

  /// 리소스 해제
  @override
  void dispose() {
    if (!_isInitialized || _appKitModal == null) return;

    // 이벤트 리스너 해제
    _appKitModal!.onModalConnect.unsubscribe(_onModalConnect);
    _appKitModal!.onModalUpdate.unsubscribe(_onModalUpdate);
    _appKitModal!.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    _appKitModal!.onModalDisconnect.unsubscribe(_onModalDisconnect);
    _appKitModal!.onModalError.unsubscribe(_onModalError);

    _isInitialized = false;
  }

  //----------------------------------- 컨트랙트 함수 -------------------------------------------
  /// 스마트 컨트랙트 함수 호출을 위한 공통 메서드
  Future<Map<String, dynamic>> _callContractFunction({
    required String contractAddress,
    required String contractAbi,
    required String functionName,
    required List<dynamic> parameters,
    String contractName = 'SubscriptionContract',
    TransactionCallback? onComplete,
    String? logPrefix,
  }) async {
    final prefix = logPrefix ?? "[WalletService] $functionName";
    dev.log("$prefix 시작: 파라미터=$parameters");

    if (!_isInitialized || _appKitModal == null) {
      final errorMsg = '지갑 서비스가 초기화되지 않았습니다.';
      dev.log("$prefix Error: $errorMsg");
      onComplete?.call(null, false, errorMsg);
      return {'success': false, 'error': errorMsg, 'txHash': null};
    }

    if (address == "none" || !_appKitModal!.isConnected) {
      final errorMsg = '지갑을 먼저 연결해주세요.';
      dev.log("$prefix Error: $errorMsg");
      onComplete?.call(null, false, errorMsg);
      return {'success': false, 'error': errorMsg, 'txHash': null};
    }

    try {
      _isTransferring = true;
      _lastTxHash = null;
      notifyListeners();

      // 컨트랙트 ABI 파싱
      final contractAbiObject = ContractAbi.fromJson(contractAbi, contractName);

      // DeployedContract 객체 생성
      final contract = DeployedContract(
        contractAbiObject,
        EthereumAddress.fromHex(contractAddress),
      );

      // 현재 체인 ID 가져오기
      final String rawChainId = _appKitModal!.selectedChain!.chainId;

      dev.log("$prefix 체인 ID: $rawChainId");

      final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(
        rawChainId,
      );
      dev.log("$prefix 네임스페이스: $namespace");
      dev.log("주소 HEX: ${_appKitModal!.session!.getAddress(namespace)!}");
      // 트랜잭션 객체 생성
      final transaction = Transaction(
        from: EthereumAddress.fromHex(
          _appKitModal!.session!.getAddress(namespace)!,
        ),
      );

      dev.log("$prefix 호출 준비");

      // 지갑 앱 실행 (서명을 위해)
      _appKitModal!.launchConnectedWallet();

      // 컨트랙트 호출 실행
      final result = await _appKitModal!.requestWriteContract(
        topic: _appKitModal!.session!.topic,
        chainId: rawChainId,
        deployedContract: contract,
        functionName: functionName,
        transaction: transaction,
        parameters: parameters,
      );

      dev.log('$prefix 트랜잭션 요청 완료: $result');

      // 트랜잭션 해시 저장
      _lastTxHash = result.toString();

      // 상태 업데이트
      _isTransferring = false;
      notifyListeners();

      // 콜백 호출
      onComplete?.call(_lastTxHash, true, null);

      // 기본 결과 맵 생성
      final resultMap = {'success': true, 'error': null, 'txHash': _lastTxHash};

      // 전달된 파라미터를 결과에 추가
      for (int i = 0; i < parameters.length; i++) {
        final param = parameters[i];
        if (param is BigInt) {
          resultMap['param$i'] = param.toString();
        } else {
          resultMap['param$i'] = param.toString();
        }
      }

      return resultMap;
    } catch (e) {
      dev.log('$prefix 트랜잭션 오류: $e');
      _isTransferring = false;
      _lastTxHash = null;
      notifyListeners();

      onComplete?.call(null, false, e.toString());

      return {'success': false, 'error': e.toString(), 'txHash': null};
    }
  }

  // ERC20 토큰 승인 함수
  Future<Map<String, dynamic>> approveERC20Token({
    required String tokenAddress,
    required String spenderAddress,
    required String amount,
    int tokenDecimals = 18,
    String? contractAbi,
    TransactionCallback? onComplete,
  }) async {
    // ERC20 컨트랙트 ABI 정의 (제공된 ABI가 없으면 기본 ABI 사용)
    final abi = jsonEncode([
      {
        "inputs": [
          {"name": "spender", "type": "address"},
          {"name": "amount", "type": "uint256"},
        ],
        "name": "approve",
        "outputs": [
          {"name": "", "type": "bool"},
        ],
        "stateMutability": "nonpayable",
        "type": "function",
      },
    ]);

    // 금액을 토큰 데시멀에 맞게 변환
    final BigInt amountInWei;
    try {
      final double parsedAmount = double.parse(amount);
      final BigInt decimalFactor = BigInt.from(10).pow(tokenDecimals);
      final double rawAmountInWei = parsedAmount * decimalFactor.toDouble();
      amountInWei = BigInt.from(rawAmountInWei.toInt());

      dev.log(
        "[WalletService] 변환된 승인 금액: $amount -> $amountInWei wei (소수점: $tokenDecimals)",
      );
    } catch (parseError) {
      final errorMsg = '금액 변환 중 오류 발생: $parseError';
      dev.log("[WalletService] Error: $errorMsg");
      onComplete?.call(null, false, errorMsg);
      return {'success': false, 'error': errorMsg, 'txHash': null};
    }

    final result = await _callContractFunction(
      contractAddress: tokenAddress,
      contractAbi: abi,
      functionName: 'approve',
      contractName: 'ERC20',
      parameters: [EthereumAddress.fromHex(spenderAddress), amountInWei],
      onComplete: onComplete,
      logPrefix: "[WalletService] approveERC20Token",
    );

    if (result['success'] == true) {
      return {
        ...result,
        'tokenAddress': tokenAddress,
        'spenderAddress': spenderAddress,
        'amount': amount,
        'decimals': tokenDecimals,
      };
    }

    return result;
  }

  // 사용자 등록 함수
  Future<Map<String, dynamic>> registerUser({
    required String contractAddress,
    required int userId,
    required String contractAbi,
    TransactionCallback? onComplete,
  }) async {
    return await _callContractFunction(
      contractAddress: contractAddress,
      contractAbi: contractAbi,
      functionName: 'registerUser',
      parameters: [BigInt.from(userId)],
      onComplete: onComplete,
      logPrefix: "[WalletService] registerUser",
    );
  }

  // 아티스트 등록 함수
  Future<Map<String, dynamic>> registerArtist({
    required String contractAddress,
    required int artistId,
    required String contractAbi,
    TransactionCallback? onComplete,
  }) async {
    return await _callContractFunction(
      contractAddress: contractAddress,
      contractAbi: contractAbi,
      functionName: 'registerArtist',
      parameters: [BigInt.from(artistId)],
      onComplete: onComplete,
      logPrefix: "[WalletService] registerArtist",
    );
  }

  // 일반 구독 함수
  Future<Map<String, dynamic>> subscribeRegular({
    required String contractAddress,
    required int userId,
    required String contractAbi,
    TransactionCallback? onComplete,
  }) async {
    return await _callContractFunction(
      contractAddress: contractAddress,
      contractAbi: contractAbi,
      functionName: 'subscribeRegular',
      parameters: [BigInt.from(userId)],
      onComplete: onComplete,
      logPrefix: "[WalletService] subscribeRegular",
    );
  }

  // 아티스트 구독 함수
  Future<Map<String, dynamic>> subscribeToArtist({
    required String contractAddress,
    required int subscriberId,
    required int artistId,
    required String contractAbi,
    TransactionCallback? onComplete,
  }) async {
    return await _callContractFunction(
      contractAddress: contractAddress,
      contractAbi: contractAbi,
      functionName: 'subscribeToArtist',
      parameters: [BigInt.from(subscriberId), BigInt.from(artistId)],
      onComplete: onComplete,
      logPrefix: "[WalletService] subscribeToArtist",
    );
  }

  // 일반 구독 취소 함수
  Future<Map<String, dynamic>> cancelRegularSubscription({
    required String contractAddress,
    required int userId,
    required String contractAbi,
    TransactionCallback? onComplete,
  }) async {
    return await _callContractFunction(
      contractAddress: contractAddress,
      contractAbi: contractAbi,
      functionName: 'cancelRegularSubscription',
      parameters: [BigInt.from(userId)],
      onComplete: onComplete,
      logPrefix: "[WalletService] cancelRegularSubscription",
    );
  }

  // 아티스트 구독 취소 함수
  Future<Map<String, dynamic>> cancelArtistSubscription({
    required String contractAddress,
    required int subscriberId,
    required int artistId,
    required String contractAbi,
    TransactionCallback? onComplete,
  }) async {
    return await _callContractFunction(
      contractAddress: contractAddress,
      contractAbi: contractAbi,
      functionName: 'cancelArtistSubscription',
      parameters: [BigInt.from(subscriberId), BigInt.from(artistId)],
      onComplete: onComplete,
      logPrefix: "[WalletService] cancelArtistSubscription",
    );
  }
}
