// lib/screens/subscription_payment_screen.dart
import 'package:ari/core/constants/contract_constants.dart';
import 'package:ari/presentation/viewmodels/subscription/artist_selection_viewmodel.dart';
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:ari/presentation/widgets/common/button_large.dart';
import 'package:ari/presentation/widgets/common/header_widget.dart';
import 'package:ari/presentation/widgets/subscription/payment/payment_agreement_section.dart';
import 'package:ari/presentation/widgets/subscription/payment/payment_info_section.dart';
import 'package:ari/presentation/widgets/subscription/payment/wallet_widget.dart';
import 'package:ari/providers/subscription/walletServiceProviders.dart';
import 'package:ari/providers/user_provider.dart';
// 새로운 StateNotifier Provider 임포트
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;

class SubscriptionPaymentScreen extends ConsumerStatefulWidget {
  final SubscriptionType subscriptionType;
  final ArtistInfo? artistInfo; // 아티스트 구독인 경우에만 사용됨
  
  const SubscriptionPaymentScreen({
    super.key,
    this.subscriptionType = SubscriptionType.regular,
    this.artistInfo,
  });

  @override
  SubscriptionPaymentScreenState createState() => SubscriptionPaymentScreenState();
}

class SubscriptionPaymentScreenState extends ConsumerState<SubscriptionPaymentScreen> {
  bool isLoading = false;
  // 약관 동의 상태 추가
  bool isAllAgreed = false;
  
  // 구독 금액 (실제로는 API나 상태 관리에서 가져올 수 있음)
  late String subscriptionAmount;
  
  @override
  void initState() {
    super.initState();
    
    // 구독 타입에 따라 금액 설정
    subscriptionAmount = widget.subscriptionType == SubscriptionType.regular ? "1" : "1";

    // StateNotifier가 자동으로 WalletService의 상태를 감시하므로
    // 추가적인 설정이 필요 없습니다.
    
    // 디버깅을 위한 로그 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // mounted 체크 추가
      if (mounted) {
        dev.log("[SubscriptionPaymentScreen] 초기화 완료");
        final walletState = ref.watch(walletStateProvider);
        dev.log("[SubscriptionPaymentScreen] 초기 지갑 상태: 연결=${walletState.isConnected}, 전송 중=${walletState.isTransferring}");
      }
    });
  }

  // mounted 체크를 포함한 안전한 setState 래퍼 함수
  void safeSetState(VoidCallback  fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // 스낵바 표시 헬퍼 메서드
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // 약관 동의 상태 업데이트 메서드
  void _updateAgreementStatus(bool allAgreed) {
    safeSetState(() {
      isAllAgreed = allAgreed;
    });
  }

  @override
  void dispose() {
    // 필요한 리소스 정리
    dev.log("[SubscriptionPaymentScreen] dispose 호출됨");
    super.dispose();
  }

  // ------------------------------- 컨트랙트 함수 -----------------------------------

  // 구독 처리 메서드
  void handleSubscription() async {
    // 이미 처리 중인 경우 중복 실행 방지
    if (isLoading) return;
    
    // 약관 동의 확인
    if (!isAllAgreed) {
      _showSnackBar('모든 약관에 동의해주세요.');
      return;
    }
    
    // mounted 체크
    if (!mounted) return;
    
    // 지갑 연결 상태 확인 - StateNotifier에서 가져옴
    final walletState = ref.read(walletStateProvider);
    if (!walletState.isConnected) {
      _showSnackBar('지갑을 연결해주세요.');
      return;
    }
    
    // 지갑 서비스 가져오기
    final walletService = ref.read(walletServiceProvider);
    
    // 지원되는 네트워크인지 확인
    final chainId = walletService.appKitModal.selectedChain?.chainId;
    dev.log("[구독] 선택된 체인 ID: $chainId");
    if (chainId == null || !walletService.linkTokenAddresses.containsKey(chainId)) {
      _showSnackBar('LINK 토큰이 지원되지 않는 네트워크입니다. Ethereum, Sepolia 또는 Polygon을 선택해주세요.');
      return;
    }
    
    safeSetState(() {
      isLoading = true;
    });
    
    try {
      // 현재 네트워크에 맞는 토큰 주소와 구독 컨트랙트 주소 가져오기
      final String tokenAddress = walletService.getCurrentLinkTokenAddress();
      final String subscriptionContractAddress = walletService.getCurrentSubscriptionContractAddress();
      
      // 현재 사용자 ID 가져오기 (이 부분은 앱의 상태 관리나 API에서 가져와야 합니다)
      int userId;
      try {
        final String userIdString = ref.read(userIdProvider) ?? '1';
        userId = int.parse(userIdString);
        dev.log("[구독] 사용자 ID: $userId");
      } catch (e) {
        // 변환 실패 시 기본값 사용
        userId = 1;
        dev.log("[구독] 사용자 ID 변환 실패, 기본값 사용: $e");
      }
    
      // 1. 먼저 ERC20 토큰 승인
      dev.log("[구독] 토큰 승인 시작: 금액=$subscriptionAmount, 네트워크=eip155:$chainId");
      _showSnackBar('토큰 승인 진행 중...');
      
      final approveResult = await walletService.approveERC20Token(
        tokenAddress: tokenAddress,
        spenderAddress: subscriptionContractAddress,
        amount: "20",
        tokenDecimals: SubscriptionConstants.linkTokenDecimals,
        onComplete: (txHash, success, errorMessage) {
          dev.log("[구독] 토큰 승인 완료: 성공=$success, 해시=$txHash, 오류=$errorMessage");
          
          // mounted 체크 추가
          if (!mounted) return;
          
          if (!success) {
            _showSnackBar('토큰 승인 실패: $errorMessage');
            safeSetState(() {
              isLoading = false;
            });
          }
        },
      );
      
      // mounted 체크 추가
      if (!mounted) return;
      
      if (!approveResult['success']) {
        _showSnackBar('토큰 승인 실패: ${approveResult['error']}');
        safeSetState(() {
          isLoading = false;
        });
        return;
      } 
      
      // 승인이 성공했다면 사용자에게 알림
      _showSnackBar('토큰 승인 완료, 사용자 등록 중...');
      
      // 잠시 대기 (사용자가 알림을 볼 수 있도록)
      await Future.delayed(const Duration(seconds: 1));
      
      // mounted 체크 추가
      if (!mounted) return;
      
      // 2. 사용자 등록 (registerUser)
      dev.log("[구독] 사용자 등록 시작: 사용자ID=$userId, 네트워크=$chainId");
      
      final registerResult = await walletService.registerUser(
        contractAddress: subscriptionContractAddress,
        userId: userId,
        contractAbi: SubscriptionConstants.subscriptionContractAbi,
        onComplete: (regTxHash, regSuccess, regErrorMessage) {
          dev.log("[구독] 사용자 등록 완료: 성공=$regSuccess, 해시=$regTxHash, 오류=$regErrorMessage");
          
          // mounted 체크 추가
          if (!mounted) return;
          
          if (!regSuccess) {
            _showSnackBar('사용자 등록 실패: $regErrorMessage');
            safeSetState(() {
              isLoading = false;
            });
          }
        },
      );
      
      // mounted 체크 추가
      if (!mounted) return;
      
      if (!registerResult['success']) {
        _showSnackBar('사용자 등록 실패: ${registerResult['error']}');
        safeSetState(() {
          isLoading = false;
        });
        return;
      }
      
      _showSnackBar('사용자 등록 완료, 구독 시작 중...');
      
      // 잠시 대기
      await Future.delayed(const Duration(seconds: 1));
      
      // mounted 체크 추가
      if (!mounted) return;
      
      // 3. 구독 시작
      var subscribeResult;
      if (widget.subscriptionType == SubscriptionType.regular) {

        dev.log("[구독] 정기 구독 시작: 사용자ID=$userId, 네트워크=$chainId");
        
        subscribeResult = await walletService.subscribeRegular(
          contractAddress: subscriptionContractAddress,
          userId: userId,
          contractAbi: SubscriptionConstants.subscriptionContractAbi,
          onComplete: (subTxHash, subSuccess, subErrorMessage) {
            dev.log("[구독] 정기 구독 완료: 성공=$subSuccess, 해시=$subTxHash, 오류=$subErrorMessage");
            
            // mounted 체크 추가
            if (!mounted) return;
            
            if (subSuccess) {
              _showSnackBar('구독이 성공적으로 완료되었습니다!');
              
              // 로딩 상태 업데이트
              safeSetState(() {
                isLoading = false;
              });
              
              // 잠시 후 홈 화면으로 이동 (스낵바를 볼 수 있도록 약간 지연)
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  // 홈 화면으로 이동 (모든 이전 화면 제거)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            } else {
              _showSnackBar('구독 처리 중 오류: $subErrorMessage');
              safeSetState(() {
                isLoading = false;
              });
            }
          },
        );
      } else {
      // 3-2 아티스트구독
        subscribeResult = await walletService.subscribeToArtist(
          contractAddress: subscriptionContractAddress,
          subscriberId: userId,
          artistId: 1, // widget.artistInfo!.id,
          contractAbi: SubscriptionConstants.subscriptionContractAbi,
          onComplete: (subTxHash, subSuccess, subErrorMessage) {
            dev.log("[구독] 정기 구독 완료: 성공=$subSuccess, 해시=$subTxHash, 오류=$subErrorMessage");
            
            // mounted 체크 추가
            if (!mounted) return;
            
            if (subSuccess) {
              _showSnackBar('구독이 성공적으로 완료되었습니다!');
              
              // 로딩 상태 업데이트
              safeSetState(() {
                isLoading = false;
              });
              
              // 잠시 후 홈 화면으로 이동 (스낵바를 볼 수 있도록 약간 지연)
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  // 홈 화면으로 이동 (모든 이전 화면 제거)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            } else {
              _showSnackBar('구독 처리 중 오류: $subErrorMessage');
              safeSetState(() {
                isLoading = false;
              });
            }
          },
        );
      }

      // mounted 체크 추가
      if (!mounted) return;
      
      if (!subscribeResult['success']) {
        _showSnackBar('구독 실패: ${subscribeResult['error']}');
        safeSetState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      dev.log("[구독] 오류 발생: $e");
      
      // mounted 체크 추가
      if (mounted) {
        _showSnackBar('오류가 발생했습니다: $e');
        safeSetState(() {
          isLoading = false;
        });
      }
    }
  }

  // ------------------------------- 컨트랙트 함수 -----------------------------------
  @override
  Widget build(BuildContext context) {
    // 디바이스 크기 가져오기
    final size = MediaQuery.of(context).size;
    
    // StateNotifier에서 지갑 상태 구독
    final walletState = ref.watch(walletStateProvider);
    final isWalletConnected = walletState.isConnected;
    final isTransferring = walletState.isTransferring;

    // 이미 트랜잭션 진행 중이면 버튼 비활성화
    // 또한 모든 약관에 동의하지 않았거나 지갑이 연결되지 않은 경우에도 비활성화
    final buttonDisabled = isTransferring || isLoading || !isAllAgreed || !isWalletConnected;
    
    final String title = widget.subscriptionType == SubscriptionType.regular 
        ? "정기 구독하기" 
        : "아티스트 구독하기";

    return Scaffold(
      backgroundColor: Colors.black,
      // SafeArea 추가하여 시스템 UI와의 충돌 방지
      body: SafeArea(
        child: Container(
          width: size.width, // 화면 너비에 맞춤
          // 고정 높이 제거하고 화면에 맞게 조정
          decoration: const BoxDecoration(color: Colors.black),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 헤더 섹션
              HeaderWidget(
                type: HeaderType.backWithTitle,
                title: "구독하기",
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              
              // 메인 컨텐츠 영역
              Expanded(
                child: SingleChildScrollView( // 스크롤 가능하게 변경
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 패딩 조정
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 결제 정보 확인 섹션
                        PaymentInfoSection(
                          subscriptionType: widget.subscriptionType == SubscriptionType.regular 
                              ? "regular" 
                              : "artist",
                          artistInfo: widget.artistInfo,
                          price: subscriptionAmount,
                        ),
                        const SizedBox(height: 30),
                        
                        // 결제 지갑 연동 섹션 (금액 자동 설정)
                        WalletWidget(
                          defaultAmount: subscriptionAmount,
                        ),
                        const SizedBox(height: 30),
                        
                        // 동의 섹션 - onAgreementStatusChanged 콜백 추가
                        PaymentAgreementSection(
                          onAgreementStatusChanged: _updateAgreementStatus,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 하단 결제 버튼
              Padding(
                padding: const EdgeInsets.all(16.0), // 패딩 추가
                child: ButtonLarge(
                  text: !isWalletConnected 
                      ? "지갑 연결 필요" 
                      : !isAllAgreed 
                        ? "약관에 모두 동의해주세요" 
                        : widget.subscriptionType == SubscriptionType.regular
                            ? "정기 구독하기"
                            : "아티스트 구독하기",
                  isLoading: isLoading || isTransferring,
                  onPressed: buttonDisabled ? null : handleSubscription,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}