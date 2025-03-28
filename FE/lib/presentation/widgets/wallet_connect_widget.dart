import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:async'; // 추가: 비동기 작업 처리를 위한 import
import 'dart:developer' as dev;

class PageWallet extends StatefulWidget {
  const PageWallet({super.key});
  @override
  State<PageWallet> createState() => _PageWalletState();
}
 
class _PageWalletState extends State<PageWallet> {
  String address = "none";
  late ReownAppKitModal appKitModal;
  
  // 고정된 송금 주소
  final String transferAddress = "0x0DF66d97998A0f7814B6aBe73Cfe666B2d03Ff69";
  // 송금 금액 컨트롤러
  final TextEditingController amountController = TextEditingController();
  // 송금 상태
  bool isTransferring = false;
  // 추가: 마지막 트랜잭션 해시를 저장
  String? lastTxHash;
  
  // 지원되는 체인 목록 (Sepolia 테스트넷과 Polygon만 허용)
  final String sepoliaChainId = "eip155:11155111";
  final String polygonChainId = "eip155:137";
  
  // 추가: 딥링크 복귀 감지를 위한 변수
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    setupWalletConnection();
  }

  void setupWalletConnection() {
    dev.log("[init]: 초기화 시작");
    appKitModal = ReownAppKitModal(
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
    appKitModal.onModalConnect.subscribe(_onModalConnect);
    appKitModal.onModalUpdate.subscribe(_onModalUpdate);
    appKitModal.onModalNetworkChange.subscribe(_onModalNetworkChange);
    appKitModal.onModalDisconnect.subscribe(_onModalDisconnect);
    appKitModal.onModalError.subscribe(_onModalError);
    
    dev.log("[init]: 이벤트 리스너 등록 완료");
    
      // 그 다음 네트워크 설정
    dev.log("[init]: 네트워크 설정 전");
    _setupSupportedNetworks();
    
    // 마지막으로 초기화
    appKitModal.init();
    dev.log("[init]: init 완료");
    
    dev.log(ReownAppKitModalNetworks.getAllSupportedNetworks(namespace: "eip155").toString());
    // 추가: 앱 활성화 감지
    final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
    binding.addPostFrameCallback((_) {
      binding.addObserver(_AppLifecycleObserver(
        onResume: () {
          dev.log('[PageWallet] 앱 상태: resumed');
        },
        onInactive: () {
          dev.log('[PageWallet] 앱 상태: inactive');
        },
        onPaused: () {
          dev.log('[PageWallet] 앱 상태: paused');
        },
      ));
    });
  }
 
  void updateAddress() {
    setState(() {
      address = appKitModal.session
              ?.getAddress(ReownAppKitModalNetworks.getNamespaceForChainId(
            appKitModal.selectedChain?.chainId ?? "1",
          )) ??
          "none";
      
      // 추가: 연결이 복원되고 트랜잭션 처리 중이었다면 트랜잭션 상태 확인
      // if (appKitModal.isConnected && isTransferring && lastTxHash != null) {
      //   checkTransactionStatus(lastTxHash!);
      // }
    });
  }

  void _setupSupportedNetworks() {
    // 기존 네트워크 제거
    ReownAppKitModalNetworks.removeSupportedNetworks('solana');
    ReownAppKitModalNetworks.removeSupportedNetworks('polkadot');
    ReownAppKitModalNetworks.removeSupportedNetworks('tron');
    ReownAppKitModalNetworks.removeSupportedNetworks('mvx');
    
    // EVM 네트워크 필터링 (Polygon과 Sepolia만 유지)
    final evmNetworks = ReownAppKitModalNetworks.getAllSupportedNetworks(namespace: 'eip155');
    // 지원할 네트워크 ID 목록
    // final supportedChainIds = [polygonChainId, sepoliaChainId];

    // 지원하지 않는 EVM 네트워크 제거
    // for (final network in evmNetworks) {
    //   if (!supportedChainIds.contains(network.chainId)) {
        // unSupportedChainIds.add(network.chainId);
  //   ReownAppKitModalNetworks.removeSupportedNetworks('eip155');
  //   //   }
  //   // }
    
  //   // 중요: Sepolia 및 Polygon 네트워크 명시적으로 추가
  //   ReownAppKitModalNetworks.addSupportedNetworks('eip155', [
  //     ReownAppKitModalNetworkInfo(
  //       name: 'Sepolia',
  //       chainId: sepoliaChainId,
  //       currency: 'ETH',
  //       rpcUrl: 'https://rpc.sepolia.org',
  //       explorerUrl: 'https://sepolia.etherscan.io',
  //       isTestNetwork: true,
  //     ),
  //   ]);
    
  //   ReownAppKitModalNetworks.addSupportedNetworks('eip155', [
  //     ReownAppKitModalNetworkInfo(
  //       name: 'Polygon',
  //       chainId: polygonChainId,
  //       currency: 'MATIC',
  //       rpcUrl: 'https://polygon-rpc.com',
  //       explorerUrl: 'https://polygonscan.com',
  //       chainIcon: 'https://cryptologos.cc/logos/polygon-matic-logo.png',
  //     ),
  //   ]);
  // }
  }

  // 송금 기능
  Future<void> transferFunds() async {
  dev.log("[transferFunds] 검사 전");
  if (address == "none" || !appKitModal.isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('지갑을 먼저 연결해주세요.')),
    );
    return;
  }
  
  if (amountController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('송금 금액을 입력해주세요.')),
    );
    return;
  }
  
  try {
    setState(() {
      isTransferring = true;
      lastTxHash = null;
    });

    // 네트워크에 따른 통화 단위
    final String nativeSymbol = appKitModal.selectedChain?.chainId == polygonChainId
        ? "MATIC" 
        : "ETH";
    
    // 트랜잭션 파라미터 설정
    final chainId = appKitModal.selectedChain!.chainId;
    final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(chainId);
    
    final txParams = {
      'to': transferAddress,
      'value': '0x${BigInt.parse((double.parse(amountController.text) * 1e18).toInt().toString()).toRadixString(16)}',
      'from': appKitModal.session!.getAddress(namespace)!,
      'gasLimit': '0x5208',
      'gasPrice': '0xBA43B7400',
    };
    
    dev.log("[transferFunds] $txParams");
    
    // 먼저 요청 생성
    final requestFuture = appKitModal.request(
      topic: appKitModal.session!.topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [txParams],
      ),
    );
    
    // 요청 생성 후 지갑 앱 실행
    appKitModal.launchConnectedWallet();
    
    // 결과 대기
    final result = await requestFuture;
    dev.log('[PageWallet] 트랜잭션 요청 완료: $result');
    
    // 트랜잭션 해시 저장
    lastTxHash = result.toString();
    
    // 성공 모달 표시
    showSuccessModal(lastTxHash!, nativeSymbol);
    amountController.clear();
  } catch (e) {
    dev.log('[PageWallet] 트랜잭션 오류: $e');
    setState(() {
      isTransferring = false;
      lastTxHash = null;
    });
    
    // 오류 모달 표시
    showErrorModal(e.toString());
  }
}
  
  // 추가: 트랜잭션 상태 확인 메서드
  // Future<void> checkTransactionStatus(String txHash) async {
  //   dev.log('[PageWallet] 트랜잭션 상태 확인: $txHash');
  //   try {
  //     // 트랜잭션 영수증 요청
  //     final result = await appKitModal.request(
  //       topic: appKitModal.session?.topic,
  //       chainId: appKitModal.selectedChain?.chainId ?? "1",
  //       request: SessionRequestParams(
  //         method: 'eth_getTransactionReceipt',
  //         params: [txHash],
  //       ),
  //     );
      
  //     dev.log('[PageWallet] 트랜잭션 영수증: $result');
      
  //     // 영수증이 있으면 트랜잭션이 완료된 것
  //     if (result != null) {
  //       setState(() {
  //         isTransferring = false;
  //       });
  //       return;
  //     }
      
  //     // 영수증이 없으면 3초 후 다시 확인
  //     Future.delayed(const Duration(seconds: 3), () {
  //       if (isTransferring && mounted) {
  //         checkTransactionStatus(txHash);
  //       }
  //     });
  //   } catch (e) {
  //     dev.log('[PageWallet] 트랜잭션 상태 확인 오류: $e');
  //     // 오류 발생 시 상태 업데이트는 하지 않고 재시도
  //     Future.delayed(const Duration(seconds: 3), () {
  //       if (isTransferring && mounted) {
  //         checkTransactionStatus(txHash);
  //       }
  //     });
  //   }
  // }

  // 송금 성공 모달
  void showSuccessModal(String txHash, String symbol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('송금 성공'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${amountController.text} $symbol을 성공적으로 송금했습니다.'),
            const SizedBox(height: 10),
            const Text('트랜잭션 ID:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                txHash,
                style: const TextStyle(fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 추가: 익스플로러 링크 안내
            const SizedBox(height: 10),
            const Text('블록체인 익스플로러에서 트랜잭션 상태를 확인할 수 있습니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 에러 모달
  void showErrorModal(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('송금 실패'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text('송금 중 오류가 발생했습니다: $errorMessage'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 잔액 조회 기능
  Future<void> fetchBalance() async {
    if (!appKitModal.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지갑을 먼저 연결해주세요.')),
      );
      return;
    }
    
    setState(() {
      isTransferring = true; // 로딩 상태 표시에 재사용
    });
    
    try {
      final result = await appKitModal.request(
        topic: appKitModal.session?.topic,
        chainId: appKitModal.selectedChain?.chainId ?? "1",
        request: SessionRequestParams(
          method: 'eth_getBalance',
          params: [address, 'latest'],
        ),
      );
      
      setState(() {
        isTransferring = false;
      });
      
      // 결과가 16진수 문자열이므로 10진수로 변환
      final String hexBalance = result.toString();
      final BigInt weiBalance = BigInt.parse(hexBalance.startsWith('0x') ? hexBalance.substring(2) : hexBalance, radix: 16);
      
      // 이더 단위로 변환 (wei / 10^18)
      final double ethBalance = weiBalance / BigInt.from(10).pow(18);
      
      // 현재 네트워크에 따른 통화 단위
      final String currency = appKitModal.selectedChain?.chainId == polygonChainId ? 'MATIC' : 'ETH';
      
      // 잔액 표시
      showBalanceDialog(ethBalance, currency);
    } catch (e) {
      setState(() {
        isTransferring = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('잔액 조회 중 오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }
  
  // 잔액 표시 다이얼로그
  void showBalanceDialog(double balance, String currency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('현재 잔액'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    balance.toStringAsFixed(6),
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '주소: ${address.substring(0, 6)}...${address.substring(address.length - 4)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 송금 모달 표시
  void showTransferModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        final String currency = appKitModal.selectedChain?.chainId == polygonChainId
            ? "MATIC" 
            : "ETH";
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '송금하기',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // 고정된 송금 주소 표시
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('송금 주소: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        transferAddress,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              // 금액 입력 필드
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '송금 금액',
                  hintText: '예: 0.01',
                  border: const OutlineInputBorder(),
                  suffixText: currency,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              
              // 송금 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    dev.log("transaction 전송 버튼 클릭");
                    transferFunds();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('$currency 송금하기'),
                ),
              ),
              const SizedBox(height: 10),
              
              // 취소 버튼
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    amountController.clear();
                  },
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  // Modal 이벤트 핸들러
  void _onModalConnect(ModalConnect? event) {
    debugPrint('[PageWallet] _onModalConnect ${event?.session.toJson()}');
    setState(() {});
    updateAddress();
  }

  void _onModalUpdate(ModalConnect? event) {
    debugPrint('[PageWallet] _onModalUpdate ${event?.session.toJson()}');
    setState(() {});
    updateAddress();
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    debugPrint('[PageWallet] _onModalNetworkChange ${event?.toString()}');
    setState(() {});
    updateAddress();
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint('[PageWallet] _onModalDisconnect ${event?.toString()}');
    setState(() {
      address = "none";
      isTransferring = false;
    });
  }

  void _onModalError(ModalError? event) {
    debugPrint('[PageWallet] _onModalError ${event?.toString()}');
    
    // Coinbase Wallet 오류 처리 (지갑에서 직접 연결 해제한 경우)
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      appKitModal.disconnect();
    }
    
    setState(() {});
  }

  @override
  void dispose() {
    // 이벤트 리스너 해제
    appKitModal.onModalConnect.unsubscribe(_onModalConnect);
    appKitModal.onModalUpdate.unsubscribe(_onModalUpdate);
    appKitModal.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    appKitModal.onModalDisconnect.unsubscribe(_onModalDisconnect);
    appKitModal.onModalError.unsubscribe(_onModalError);
    
    amountController.dispose();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('내 지갑'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // 추가: 잔액 조회 버튼
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: appKitModal.isConnected ? fetchBalance : null,
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
                        appKit: appKitModal,
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppKitModalConnectButton(
                        appKit: appKitModal,
                        context: context,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 계정 정보 영역
          if (appKitModal.isConnected) ...[
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
                          appKitModal: appKitModal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppKitModalAddressButton(
                          appKitModal: appKitModal,
                          onTap: appKitModal.openModalView,
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
                onPressed: appKitModal.isConnected ? showTransferModal : null,
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
      
      // 로딩 인디케이터
      bottomSheet: isTransferring
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
                    '${appKitModal.selectedChain?.chainId == polygonChainId ? "MATIC" : "ETH"} ${lastTxHash != null ? "상태 확인 중..." : "송금 중..."}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// 추가: 앱 생명주기 관찰자 클래스
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback? onInactive;
  final VoidCallback? onPaused;
  
  _AppLifecycleObserver({
    required this.onResume,
    this.onInactive,
    this.onPaused,
  });
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.inactive:
        onInactive?.call();
        break;
      case AppLifecycleState.paused:
        onPaused?.call();
        break;
      default:
        break;
    }
  }
}
