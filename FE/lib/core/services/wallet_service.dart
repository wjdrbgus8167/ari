// lib/services/wallet_service.dart
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:async';
import 'dart:developer' as dev;
import '../constants/chain_constants.dart';

// 트랜잭션 상태 관리를 위한 상태 enum
enum TransactionState {
  idle,
  transferring,
  checkingStatus,
  completed,
  error
}

class WalletService {
  late ReownAppKitModal appKitModal;
  String address = "none";
  bool isConnected = false;
  String? lastTxHash;
  
  
  // 현재 트랜잭션 상태
  TransactionState _transactionState = TransactionState.idle;
  // 오류 메시지
  String? _errorMessage;
  
  // 상태 및 메시지 접근자
  TransactionState get transactionState => _transactionState;
  String? get errorMessage => _errorMessage;
  
  // 상태 변경 콜백
  final Function(TransactionState) onTransactionStateChanged;
  
  // 접속된 네트워크에서 사용하는 통화 단위 계산
  String get currencySymbol => ChainConstants.getCurrencySymbol(appKitModal.selectedChain?.chainId);
  
  WalletService({
    required BuildContext context,
    required this.onTransactionStateChanged,
  }) {
    _initWalletModal(context);
  }
  
  // 지갑 모달 초기화
  void _initWalletModal(BuildContext context) {
    dev.log("[WalletService] 초기화 시작");
    
    appKitModal = ReownAppKitModal(
      context: context,
      projectId: ChainConstants.projectId,
      metadata: const PairingMetadata(
        name: ChainConstants.appName,
        description: ChainConstants.appDescription,
        url: ChainConstants.appUrl,
        icons: [ChainConstants.appIcon],
        redirect: Redirect(
          native: ChainConstants.appRedirectNative,
          universal: ChainConstants.appRedirectUniversal,
          linkMode: true,
        ),
      ),
    );
    
    // 이벤트 리스너 등록
    _registerEventListeners();
    
    // 네트워크 설정
    _setupSupportedNetworks();
    
    // 초기화
    appKitModal.init();
    dev.log("[WalletService] init 완료");
  }
  
  // 이벤트 리스너 등록
  void _registerEventListeners() {
    appKitModal.onModalConnect.subscribe(_onModalConnect);
    appKitModal.onModalUpdate.subscribe(_onModalUpdate);
    appKitModal.onModalNetworkChange.subscribe(_onModalNetworkChange);
    appKitModal.onModalDisconnect.subscribe(_onModalDisconnect);
    appKitModal.onModalError.subscribe(_onModalError);
    
    dev.log("[WalletService] 이벤트 리스너 등록 완료");
  }
  
  // 이벤트 리스너 해제
  void dispose() {
    appKitModal.onModalConnect.unsubscribe(_onModalConnect);
    appKitModal.onModalUpdate.unsubscribe(_onModalUpdate);
    appKitModal.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    appKitModal.onModalDisconnect.unsubscribe(_onModalDisconnect);
    appKitModal.onModalError.unsubscribe(_onModalError);
  }
  
  // 지원 네트워크 설정
  void _setupSupportedNetworks() {
    // 기존 네트워크 제거
    ReownAppKitModalNetworks.removeSupportedNetworks('solana');
    ReownAppKitModalNetworks.removeSupportedNetworks('polkadot');
    ReownAppKitModalNetworks.removeSupportedNetworks('tron');
    ReownAppKitModalNetworks.removeSupportedNetworks('mvx');
    
    // EVM 네트워크 필터링 가능 (필요시 주석 해제)
    // ReownAppKitModalNetworks.removeSupportedNetworks('eip155');
    
    // Sepolia 및 Polygon 네트워크를 명시적으로 추가하려면 주석 해제
    // _addCustomNetworks();
  }
  
  // 사용자 지정 네트워크 추가
  /*
  void _addCustomNetworks() {
    ReownAppKitModalNetworks.addSupportedNetworks('eip155', [
      ReownAppKitModalNetworkInfo(
        name: 'Sepolia',
        chainId: ChainConstants.sepoliaChainId,
        currency: 'ETH',
        rpcUrl: 'https://rpc.sepolia.org',
        explorerUrl: 'https://sepolia.etherscan.io',
        isTestNetwork: true,
      ),
    ]);
    
    ReownAppKitModalNetworks.addSupportedNetworks('eip155', [
      ReownAppKitModalNetworkInfo(
        name: 'Polygon',
        chainId: ChainConstants.polygonChainId,
        currency: 'MATIC',
        rpcUrl: 'https://polygon-rpc.com',
        explorerUrl: 'https://polygonscan.com',
        chainIcon: 'https://cryptologos.cc/logos/polygon-matic-logo.png',
      ),
    ]);
  }
  */
  
  // 주소 업데이트
  void updateAddress() {
    address = appKitModal.session
        ?.getAddress(ReownAppKitModalNetworks.getNamespaceForChainId(
            appKitModal.selectedChain?.chainId ?? "1",
        )) ??
        "none";
    isConnected = appKitModal.isConnected;
    
    // 트랜잭션 처리 중이었다면 상태 확인
    if (isConnected && _transactionState == TransactionState.transferring && lastTxHash != null) {
      _setTransactionState(TransactionState.checkingStatus);
      // checkTransactionStatus(lastTxHash!);  // 필요시 주석 해제
    }
  }
  
  // 송금 기능
  Future<String?> transferFunds(String amount) async {
    dev.log("[WalletService] 송금 시작");
    
    if (!appKitModal.isConnected) {
      throw Exception('지갑이 연결되어 있지 않습니다.');
    }
    
    if (amount.isEmpty) {
      throw Exception('송금 금액이 입력되지 않았습니다.');
    }
    
    // 상태 업데이트
    _setTransactionState(TransactionState.transferring);
    lastTxHash = null;
    _errorMessage = null;
    
    try {
      // 트랜잭션 파라미터 설정
      final chainId = appKitModal.selectedChain!.chainId;
      final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
      final currency = ChainConstants.getCurrencySymbol(chainId);
      
      final txParams = {
        'to': ChainConstants.transferAddress,
        'value': '0x${BigInt.parse((double.parse(amount) * 1e18).toInt().toString()).toRadixString(16)}',
        'from': appKitModal.session!.getAddress(namespace)!,
        'gasLimit': '0x5208',
        'gasPrice': '0xBA43B7400',
      };
      
      dev.log("[WalletService] 트랜잭션 파라미터: $txParams");
      
      // 요청 생성
      final requestFuture = appKitModal.request(
        topic: appKitModal.session!.topic,
        chainId: chainId,
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [txParams],
        ),
      );
      
      // 지갑 앱 실행
      appKitModal.launchConnectedWallet();
      
      // 결과 대기
      final result = await requestFuture;
      dev.log('[WalletService] 트랜잭션 요청 완료: $result');
      
      // 트랜잭션 해시 저장
      lastTxHash = result.toString();
      
      // 상태 업데이트
      _setTransactionState(TransactionState.completed);
      
      return lastTxHash;
    } catch (e) {
      dev.log('[WalletService] 트랜잭션 오류: $e');
      
      // 오류 상태 업데이트
      _errorMessage = e.toString();
      _setTransactionState(TransactionState.error);
      
      rethrow;
    }
  }
  
  // 잔액 조회 기능
  Future<double> fetchBalance() async {
    if (!appKitModal.isConnected) {
      throw Exception('지갑이 연결되어 있지 않습니다.');
    }
    
    // 로딩 상태로 변경
    _setTransactionState(TransactionState.transferring);
    
    try {
      final result = await appKitModal.request(
        topic: appKitModal.session?.topic,
        chainId: appKitModal.selectedChain?.chainId ?? "1",
        request: SessionRequestParams(
          method: 'eth_getBalance',
          params: [address, 'latest'],
        ),
      );
      
      // 상태 리셋
      _setTransactionState(TransactionState.idle);
      
      // 결과가 16진수 문자열이므로 10진수로 변환
      final String hexBalance = result.toString();
      final BigInt weiBalance = BigInt.parse(hexBalance.startsWith('0x') ? hexBalance.substring(2) : hexBalance, radix: 16);
      
      // 이더 단위로 변환 (wei / 10^18)
      final double ethBalance = weiBalance / BigInt.from(10).pow(18);
      
      return ethBalance;
    } catch (e) {
      // 오류 상태 업데이트
      _errorMessage = e.toString();
      _setTransactionState(TransactionState.error);
      rethrow;
    }
  }
  
  // 상태 업데이트 메서드
  void _setTransactionState(TransactionState state) {
    if (_transactionState != state) {
      _transactionState = state;
      onTransactionStateChanged(state);
    }
  }
  
  // 모달 이벤트 핸들러
  void _onModalConnect(ModalConnect? event) {
    dev.log('[WalletService] _onModalConnect ${event?.session.toJson()}');
    isConnected = true;
    updateAddress();
  }

  void _onModalUpdate(ModalConnect? event) {
    dev.log('[WalletService] _onModalUpdate ${event?.session.toJson()}');
    updateAddress();
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    dev.log('[WalletService] _onModalNetworkChange ${event?.toString()}');
    updateAddress();
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    dev.log('[WalletService] _onModalDisconnect ${event?.toString()}');
    address = "none";
    isConnected = false;
    
    // 트랜잭션 중이었다면 상태 초기화
    if (_transactionState == TransactionState.transferring || 
        _transactionState == TransactionState.checkingStatus) {
      _setTransactionState(TransactionState.idle);
    }
  }

  void _onModalError(ModalError? event) {
    dev.log('[WalletService] _onModalError ${event?.toString()}');
    
    // Coinbase Wallet 오류 처리 (지갑에서 직접 연결 해제한 경우)
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      appKitModal.disconnect();
    }
  }
}