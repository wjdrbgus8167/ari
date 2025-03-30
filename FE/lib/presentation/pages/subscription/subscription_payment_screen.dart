// lib/pages/wallet/page_wallet.dart
import 'package:ari/core/services/wallet_service.dart';
import 'package:ari/core/utils/app_lifecycle_observer.dart';
import 'package:ari/presentation/widgets/subscription/payment/balance_dialog.dart';
import 'package:ari/presentation/widgets/subscription/payment/transaction_dialogs.dart';
import 'package:ari/presentation/widgets/subscription/payment/transfer_modal.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:developer' as dev;

class SubscriptionPaymentScreen extends StatefulWidget {
  const SubscriptionPaymentScreen({super.key});
  
  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreen();
}
 
class _SubscriptionPaymentScreen extends State<SubscriptionPaymentScreen> {
  // 지갑 서비스
  late WalletService _walletService;
  
  // 송금 금액 컨트롤러
  final TextEditingController _amountController = TextEditingController();
  
  // 상태 변수
  bool get isConnected => _walletService.isConnected;
  String get address => _walletService.address;
  late AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    
    // 지갑 서비스 초기화
    _walletService = WalletService(
      context: context, 
      onTransactionStateChanged: _handleTransactionStateChanged,
    );
    
    // 앱 활성화 감지
    final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
    _lifecycleObserver = AppLifecycleObserver(
      onResume: () {
        dev.log('[SubscriptionPayment] 앱 상태: resumed - 상태 업데이트');
        setState(() {}); // UI 업데이트
      },
      onInactive: () {
        dev.log('[SubscriptionPayment] 앱 상태: inactive');
      },
      onPaused: () {
        dev.log('[SubscriptionPayment] 앱 상태: paused');
      },
    );
    binding.addObserver(_lifecycleObserver);
  }

  // 트랜잭션 상태 변경 이벤트 핸들러
  void _handleTransactionStateChanged(TransactionState state) {
    dev.log('[SubscriptionPayment] 트랜잭션 상태 변경: $state');
    setState(() {}); // UI 갱신
  }

  // 송금 기능
  Future<void> _transferFunds() async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지갑을 먼저 연결해주세요.')),
      );
      return;
    }
    
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('송금 금액을 입력해주세요.')),
      );
      return;
    }
    
    try {
      final amount = _amountController.text;
      final txHash = await _walletService.transferFunds(amount);
      
      if (txHash != null) {
        // 성공 모달 표시
        TransactionDialogs.showSuccess(
          context, 
          txHash, 
          amount, 
          _walletService.currencySymbol
        );
        _amountController.clear();
      }
    } catch (e) {
      dev.log('[PageWallet] 송금 실패: ${e.toString()}');
      // 오류 모달 표시
      TransactionDialogs.showError(context, e.toString());
    }
  }

  // 잔액 조회 기능
  Future<void> _fetchBalance() async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지갑을 먼저 연결해주세요.')),
      );
      return;
    }
    
    try {
      final balance = await _walletService.fetchBalance();
      
      // 잔액 다이얼로그 표시
      BalanceDialog.show(
        context, 
        balance, 
        _walletService.currencySymbol, 
        address
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('잔액 조회 중 오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }

  // 송금 모달 표시
  void _showTransferModal() {
    TransferModal.show(
      context: context,
      currency: _walletService.currencySymbol,
      amountController: _amountController,
      onTransferPressed: _transferFunds,
    );
  }

  @override
  void dispose() {
    _walletService.dispose();
    _amountController.dispose();
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 트랜잭션 상태에 따른 표시 메시지
    String getTransactionStatusMessage() {
      switch (_walletService.transactionState) {
        case TransactionState.transferring:
          return "${_walletService.currencySymbol} 송금 중...";
        case TransactionState.checkingStatus:
          return "${_walletService.currencySymbol} 상태 확인 중...";
        default:
          return "";
      }
    }

    // 로딩 상태 표시 여부
    bool showLoading = _walletService.transactionState == TransactionState.transferring ||
                      _walletService.transactionState == TransactionState.checkingStatus;
                     
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('내 지갑'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // 잔액 조회 버튼
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: isConnected ? _fetchBalance : null,
            tooltip: '잔액 조회',
          ),
        ],
      ),
      body: Column(
        children: [
          // 네트워크 선택 및 연결 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '네트워크 선택',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppKitModalNetworkSelectButton(
                        appKit: _walletService.appKitModal,
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppKitModalConnectButton(
                        appKit: _walletService.appKitModal,
                        context: context,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 계정 정보 영역
          if (isConnected) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계정 정보',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppKitModalAccountButton(
                          appKitModal: _walletService.appKitModal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppKitModalAddressButton(
                          appKitModal: _walletService.appKitModal,
                          onTap: _walletService.appKitModal.openModalView,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 송금 버튼
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: isConnected ? _showTransferModal : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.send),
                label: const Text(
                  '송금하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
      
      // 로딩 인디케이터 (트랜잭션 상태에 따라 표시)
      bottomSheet: showLoading
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    getTransactionStatusMessage(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}