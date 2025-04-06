import 'package:ari/core/services/wallet_service.dart';
import 'package:ari/providers/subscription/walletServiceProviders.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class WalletWidget extends ConsumerStatefulWidget {
  // 외부에서 트랜잭션 완료 후 호출될 콜백
  final TransactionCallback? onTransactionComplete;
  final bool useScaffold;
  final String? defaultAmount; // 기본 송금 금액 (옵션)

  const WalletWidget({
    super.key,
    this.useScaffold = false,
    this.onTransactionComplete,
    this.defaultAmount,
  });
  
  @override
  ConsumerState<WalletWidget> createState() => _WalletWidgetState();
}
 
class _WalletWidgetState extends ConsumerState<WalletWidget> {
  // Provider에서 지갑 서비스 가져오기
  WalletService get _walletService => ref.read(walletServiceProvider);
  
  // 송금 금액 컨트롤러
  final TextEditingController amountController = TextEditingController();
  
  // 초기화 여부
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    // 이후에 빌드 후 초기화하도록 스케줄링
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWalletService();
    });
    
    // 기본 금액이 있으면 설정
    if (widget.defaultAmount != null) {
      amountController.text = widget.defaultAmount!;
    }
  }
  
  // 지갑 서비스 초기화
  void _initializeWalletService() {
    try {
      // 지갑 서비스 초기화
      _walletService.initialize(context);
      
      // 이벤트 리스너 설정
      _setupEventListeners();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('지갑 서비스 초기화 오류: $e');
    }
  }
  
  // 이벤트 리스너 설정
  void _setupEventListeners() {
    _walletService.onConnect = (_) => setState(() {});
    _walletService.onDisconnect = (_) => setState(() {});
    _walletService.onUpdate = (_) => setState(() {});
    _walletService.onNetworkChange = (_) => setState(() {});
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 상태 변경 감지
    final isConnected = ref.watch(walletConnectedProvider);
    final isTransferring = ref.watch(walletTransferringProvider);
    
    // 초기화 전이면 로딩 표시
    if (!_isInitialized) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                '지갑 서비스 초기화 중...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    
    // 내부 컨텐츠 위젯
    Widget content = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '네트워크 선택 및 지갑 연결',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          // 네트워크 선택 및 연결 버튼 행
          Row(
            children: [
              Expanded(
                child: AppKitModalNetworkSelectButton(
                  appKit: _walletService.appKitModal,
                  custom: InkWell(
                    onTap: () {
                      // 네트워크 선택 모달 직접 열기
                      _walletService.appKitModal.openNetworksView();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.language,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _walletService.appKitModal.selectedChain?.name ?? '네트워크 선택',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppKitModalConnectButton(
                  appKit: _walletService.appKitModal,
                  custom: InkWell(
                    onTap: () {
                      if (_walletService.appKitModal.isConnected) {
                        // 이미 연결된 경우 연결 해제
                        _walletService.appKitModal.disconnect();
                      } else {
                        // 연결되지 않은 경우 연결 모달 열기
                        _walletService.appKitModal.openModalView();
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8E54E9).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _walletService.appKitModal.isConnected 
                                  ? Icons.account_balance_wallet 
                                  : Icons.link,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _walletService.appKitModal.isConnected
                                  ? '${_walletService.appKitModal.session!
                                        .getAddress(ReownAppKitModalNetworks
                                          .getNamespaceForChainId(_walletService.appKitModal.session!.chainId))
                                        ?.substring(0, 6)}...'
                                  : '지갑 연결',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),        
          // 로딩 인디케이터 (전송 중일 때)
          if (isTransferring) ...[
            const SizedBox(height: 16),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '트랜잭션 처리 중...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
    
    // 상위 컴포넌트에서 Scaffold 사용 여부에 따라 반환
    if (widget.useScaffold) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('내 지갑'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ),
      );
    } else {
      // Scaffold 없이 내부 컨텐츠만 반환
      return content;
    }
  }
}