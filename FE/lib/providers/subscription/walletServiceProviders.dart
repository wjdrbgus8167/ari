import 'package:ari/core/services/wallet_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;

// WalletService 싱글톤 인스턴스를 제공하는 Provider
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

// 지갑 연결 상태를 제공하는 StateProvider
final StateProvider<bool> walletConnectedProvider = StateProvider<bool>((ref) {
  // 초기값은 walletService의 isConnected 값
  final walletService = ref.watch(walletServiceProvider);
  print("[SubscriptionPaymentScreen] 현재 지갑 연결 상태: ${walletService.isConnected}");
  return walletService.isConnected;
});

// 전송 진행 중 상태를 제공하는 StateProvider
final StateProvider<bool> walletTransferringProvider = StateProvider<bool>((ref) {
  // 초기값은 walletService의 isTransferring 값
  final walletService = ref.watch(walletServiceProvider);
  return walletService.isTransferring;
});

// 지갑 상태를 관리하는 클래스
class WalletState {
  final bool isConnected;
  final bool isTransferring;
  final String? address;

  WalletState({
    this.isConnected = false,
    this.isTransferring = false,
    this.address,
  });

  WalletState copyWith({
    bool? isConnected,
    bool? isTransferring,
    String? address,
  }) {
    return WalletState(
      isConnected: isConnected ?? this.isConnected,
      isTransferring: isTransferring ?? this.isTransferring,
      address: address ?? this.address,
    );
  }
}

// StateNotifier 구현
class WalletStateNotifier extends StateNotifier<WalletState> {
  final WalletService _walletService;
  bool _disposed = false; // dispose 상태 추적
  
  WalletStateNotifier(this._walletService) : super(WalletState(
    isConnected: _walletService.isConnected,
    isTransferring: _walletService.isTransferring,
    address: _walletService.address == "none" ? null : _walletService.address,
  )) {
    _setupListeners();
  }
  
  void _setupListeners() {
    // 연결 콜백 설정
    _walletService.onConnect = (_) {
      if (_disposed) return; // dispose 체크 추가
      dev.log("[WalletStateNotifier] 지갑 연결됨");
      state = state.copyWith(
        isConnected: true,
        address: _walletService.address == "none" ? null : _walletService.address,
      );
    };
    
    // 연결 해제 콜백 설정
    _walletService.onDisconnect = (_) {
      if (_disposed) return; // dispose 체크 추가
      dev.log("[WalletStateNotifier] 지갑 연결 해제됨");
      state = state.copyWith(
        isConnected: false,
        address: null,
      );
    };
    
    // 상태 변경 리스너
    _walletService.addListener(_onServiceChanged);
  }
  
  // 상태 변경 리스너 함수 분리
  void _onServiceChanged() {
    if (_disposed) return; // dispose 체크 추가
    dev.log("[WalletStateNotifier] WalletService 변경 감지");
    state = state.copyWith(
      isConnected: _walletService.isConnected,
      isTransferring: _walletService.isTransferring,
      address: _walletService.address == "none" ? null : _walletService.address,
    );
  }
  
  // 수동으로 상태 업데이트 (필요한 경우)
  void updateConnectionState(bool isConnected) {
    if (_disposed) return; // dispose 체크 추가
    dev.log("[WalletStateNotifier] 연결 상태 수동 업데이트: $isConnected");
    state = state.copyWith(isConnected: isConnected);
  }
  
  void updateTransferringState(bool isTransferring) {
    if (_disposed) return; // dispose 체크 추가
    state = state.copyWith(isTransferring: isTransferring);
  }
  
  @override
  void dispose() {
    _disposed = true;
    // 리스너 해제
    _walletService.onConnect = null;
    _walletService.onDisconnect = null;
    _walletService.removeListener(_onServiceChanged);
    super.dispose();
  }
}

// Provider 정의 - autoDispose 추가
final walletStateProvider = StateNotifierProvider.autoDispose<WalletStateNotifier, WalletState>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  return WalletStateNotifier(walletService);
});